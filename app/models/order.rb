class Order < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :parent, polymorphic: true
  belongs_to :collaboration, -> { where(orders: {parent_type: 'Collaboration'}) }, foreign_key: 'parent_id'
  belongs_to :user

  validates :payment_type, :amount, :payable_at, presence: true

  STATUS = {"Nueva" => 0, "Sin confirmar" => 1, "OK" => 2, "Alerta" => 3, "Error" => 4, "Devuelta" => 5}
  PAYMENT_TYPES = {
    "Suscripción con Tarjeta de Crédito/Débito" => 1, 
    "Domiciliación en cuenta bancaria (CCC)" => 2, 
    "Domiciliación en cuenta extranjera (IBAN)" => 3 
  }

  PARENT_CLASSES = {
    Collaboration => "C"
  }

  REDSYS_SERVER_TIME_ZONE = ActiveSupport::TimeZone.new("Madrid")

  scope :created, -> { where(deleted_at: nil) }
  scope :by_date, -> date_start, date_end { created.where(payable_at: date_start.beginning_of_month..date_end.end_of_month ) }
  scope :credit_cards, -> { created.where(payment_type: 1)}
  scope :banks, -> { created.where.not(payment_type: 1)}
  scope :to_be_paid, -> { created.where(status:[0,1]) }
  scope :to_be_charged, -> { created.where(status:0) }
  scope :charging, -> { created.where(status:1) }
  scope :paid, -> { created.where(status:[2,3]).where.not(payed_at:nil) }
  scope :warnings, -> { created.where(status:3) }
  scope :errors, -> { created.where(status:4) }
  scope :returned, -> { created.where(status:5) }
  scope :deleted, -> { only_deleted }

  scope :full_view, -> { with_deleted.includes(:user) }

  after_initialize do |o|
    o.status = 0 if o.status.nil?
  end

  def is_payable?
    self.status<2
  end

  def is_chargable?
    self.status == 0
  end

  def is_paid?
    !self.payed_at.nil? and [2,3].include? self.status 
  end

  def has_warnings?
    self.status == 3
  end

  def has_errors?
    self.status == 4
  end

  def was_returned?
    self.status == 5
  end

  def status_name
    Order::STATUS.invert[self.status]
  end

  def error_message
    case self.status
    when 4
      case self.payment_type
      when 1
        self.redsys_text_status
      else
        ""
      end
    when 5
      "Devuelta"
    else
      ""
    end
  end

  def self.parent_from_order_id order_id
    Order::PARENT_CLASSES.invert[order_id[7]].find(order_id[0..7].to_i)
  end

  def self.payment_day
    Rails.application.secrets.orders["payment_day"].to_i
  end

  def self.by_month_count(date)
    self.by_date(date,date).count
  end

  def self.by_month_amount(date)
    self.by_date(date,date).sum(:amount) / 100.0
  end


  def admin_permalink
    admin_order_path(self)
  end

  #### BANK PAYMENTS ####

  # USAMOS order_id
  #def receipt
    # TODO order receipt
    # Es el identificador del cargo a todos los efectos y no se ha de repetir en la remesa y en las remesas sucesivas. Es un nº correlativo
  #end

  def due_code
    # CÓDIGO DE ADEUDO  Se pondra FRST cuando sea el primer cargo desde la fecha de alta, y RCUR en los siguientes sucesivos
    # TODO codigo de adeudo
    self.first ? "FRST" : "RCUR"
  end

  def url_source
    # URL FUENTE  "Este campo no se si existira en el nuevo entorno. Si no es asi poner por defecto https://podemos.info/participa/colaboraciones/colabora/
    # TODO url_source
    new_collaboration_url
  end

  # USAMOS reference
  #def concept
    # COMPROBACIÓN  Es el texto que aparecefrá en el recibo. Sera "Colaboracion "mes x"
    # TODO comprobación / concepto
  #  "Colaboración mes de XXXX"
  #end

  def mark_as_charging
    self.status = 1
  end
  
  def mark_as_paid! date
    self.status = 2 
    self.payed_at = date
    self.save
    if self.parent
      self.parent.payment_processed self
    end 
  end

  def mark_as_returned!
    self.status = 5
    self.save
    if self.parent
      self.parent.returned_order
    end
  end

  def self.mark_bank_orders_as_charged! date
    Order.banks.by_date(Date.today,Date.today).to_be_charged.update_all(status:1)
  end
  def self.mark_bank_orders_as_paid! date
    Order.banks.by_date(Date.today,Date.today).charging.update_all(status:2)
  end


  #### REDSYS CC PAYMENTS ####

  def redsys_secret(key)
    Rails.application.secrets.redsys[key]
  end

  def redsys_expiration
    # Credit card is valid until the last day of expiration month
    DateTime.strptime(self.redsys_response["Ds_ExpiryDate"], "%y%m") + 1.month - 1.seconds if self.redsys_response
  end

  def redsys_order_id
    @order_id ||= 
      if self.redsys_response
        self.redsys_response["Ds_Order"]
      else
        if self.persisted?
          self.id.to_s.rjust(12, "0")
        else
          self.parent.id.to_s.rjust(7, "0") + Order::PARENT_CLASSES[parent.class] + Time.now.to_i.to_s(36)[-4..-1]
        end
      end
  end
    
  def redsys_post_url
    redsys_secret "post_url"
  end

  def redsys_merchant_url
    if self.first
      orders_callback_redsys_url(protocol: if Rails.env.development? then :http else :https end, redsys_order_id: self.redsys_order_id, user_id: self.user_id, parent_id: self.parent.id)
    else
      ""
    end
  end

  def redsys_merchant_request_signature
    msg = "#{self.amount}#{self.redsys_order_id}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_secret "transaction_type"}#{self.redsys_merchant_url}"
    msg = if self.first
            "#{msg}#{self.redsys_secret "identifier"}#{self.redsys_secret "secret_key"}"
          else
            "#{msg}#{self.payment_identifier}true#{self.redsys_secret "secret_key"}"   
          end

    Digest::SHA1.hexdigest(msg).upcase
  end

  def redsys_merchant_response_signature
    msg = "#{self.amount}#{self.redsys_order_id}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_response['Ds_Response']}#{self.redsys_secret "secret_key"}"
    Digest::SHA1.hexdigest(msg).upcase
  end
  
  def redsys_logger
    @@redsys_logger ||= Logger.new("#{Rails.root}/log/redsys.log")
  end

  def redsys_response
    @redsys_response ||= if self.payment_response.nil? then nil else JSON.parse(self.payment_response) end
  end

  def redsys_parse_response! params
    redsys_logger.info("*" * 40)
    redsys_logger.info("Redsys: New payment")
    redsys_logger.info("User: #{self.user_id} - #{self.parent.class.to_s}: #{self.parent.id}")
    redsys_logger.info("Data: #{self.attributes.inspect}")
    redsys_logger.info("Params: #{params}")
    self.payment_response = params.to_json

    if params["Ds_Response"].to_i < 100
      self.payed_at = Time.now
      begin
        payment_date = REDSYS_SERVER_TIME_ZONE.parse "#{params["Ds_Date"]} #{params["Ds_Hour"]}"
        if (payment_date-1.hours) < Time.now and Time.now < (payment_date+1.hours) and params["user_id"].to_i == self.user_id and params["Ds_Signature"] == self.redsys_merchant_response_signature
          redsys_logger.info("Status: OK")
          self.status = 2
        else
          redsys_logger.info("Status: OK, but with warnings")
          self.status = 3
        end
        self.payment_identifier = params["Ds_Merchant_Identifier"]
      rescue
        redsys_logger.info("Status: OK, but with errors on response processing.")
        redsys_logger.info("Error: #{$!.message}")
        redsys_logger.info("Backtrace: #{$!.backtrace}")
        self.status = 3
      end
    else
      redsys_logger.info("Status: KO - ERROR")
      self.status = 4
    end
    self.save

    if self.parent
      self.parent.payment_processed self
    end    
  end

  def redsys_params
    extra = if self.first 
            {
              "Ds_Merchant_Identifier"        => self.redsys_secret("identifier"),
              "Ds_Merchant_UrlOK"             => self.parent.ok_url,
              "Ds_Merchant_UrlKO"             => self.parent.ko_url
            }
            else
            {
              "Ds_Merchant_Identifier"        => self.payment_identifier,
              'Ds_Merchant_DirectPayment'     => 'true'
            }
            end

    {
      "Ds_Merchant_Currency"          => self.redsys_secret("currency"),
      "Ds_Merchant_MerchantCode"      => self.redsys_secret("code"),
      "Ds_Merchant_MerchantName"      => self.redsys_secret("name"),
      "Ds_Merchant_Terminal"          => self.redsys_secret("terminal"),
      "Ds_Merchant_TransactionType"   => self.redsys_secret("transaction_type"),
      "Ds_Merchant_PayMethods"        => self.redsys_secret("payment_methods"),
      "Ds_Merchant_MerchantData"      => self.user_id,
      "Ds_Merchant_MerchantURL"       => self.redsys_merchant_url,
      "Ds_Merchant_Order"             => self.redsys_order_id,
      "Ds_Merchant_Amount"            => self.amount,
      "Ds_Merchant_MerchantSignature" => self.redsys_merchant_request_signature
    }.merge extra

  end

  def redsys_send_request
    uri = URI self.redsys_post_url

    http = Net::HTTP.new uri.host, uri.port
    if uri.scheme == 'https'
      http.use_ssl = true
      if Rails.env.production?
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      #http.ssl_options = OpenSSL::SSL::OP_NO_SSLv2 + OpenSSL::SSL::OP_NO_SSLv3 + OpenSSL::SSL::OP_NO_COMPRESSION
      http.ssl_version = :TLSv1
    end

    self.save
    response = http.post(uri, URI.encode_www_form(self.redsys_params))
    info = (response.body.scan /<!--\W*(\w*)\W*-->/).flatten
    self.payment_response = info.to_json
    if info[0] == "RSisReciboOK"
      self.payed_at = Time.now
      self.status = 2
    else
      self.status = 4
    end
    self.save
    
    if self.parent
      self.parent.payment_processed self
    end
  end

  def redsys_text_status
    if self.redsys_response

      # Given a status code, returns the status message
      case self.redsys_response["Ds_Response"].to_i
        when 0..99      then "Transacción autorizada para pagos y preautorizaciones"
        when 900        then "Transacción autorizada para devoluciones y confirmaciones"
        when 101        then "Tarjeta caducada"
        when 102        then "Tarjeta en excepción transitoria o bajo sospecha de fraude"
        when 104, 9104  then "Operación no permitida para esa tarjeta o terminal"
        when 116        then "Disponible insuficiente"
        when 118        then "Tarjeta no registrada"
        when 129        then "Código de seguridad (CVV2/CVC2) incorrecto"
        when 180        then "Tarjeta ajena al servicio"
        when 184        then "Error en la autenticación del titular"
        when 190        then "Denegación sin especificar Motivo"
        when 191        then "Fecha de caducidad errónea"
        when 202        then "Tarjeta en excepción transitoria o bajo sospecha de fraude con retirada de tarjeta"
        when 912, 9912  then "Emisor no disponible"
        else
          "Transacción denegada"
      end
    else
      "Transacción no procesada"
    end
  end
end
