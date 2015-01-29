class Order < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :parent, polymorphic: true
  belongs_to :user

  validates :payment_type, :payment_identifier, :amount, :user_id, :payable_at, presence: true

  STATUS = [["pendiente", 1], ["pagado", 2], ["error", 3]]
  TYPES = [
    ["Suscripción con Tarjeta de Crédito/Débito", 1], 
    ["Domiciliación en cuenta bancaria (CCC)", 2], 
    ["Domiciliación en cuenta extranjera (IBAN)", 3], 
  ]

  PARENT_CLASSES = {
    Collaboration => "C"
  }

  after_initialize do |o|
    o.status = 1 if o.status.nil?
  end

  def payed?
    self.status == 2
  end

  def status_name
    Order::STATUS.select{|v| v[1] == self.status }[0][0]
  end

  def text_status
    message = ""
    message = ": "+self.redsys_text_status if self.payment_type==3 and self.status==3
    status_name+message
  end

  def self.parent_from_order_id order_id
    Order::PARENT_CLASSES.invert[order_id[7]].find(order_id[0..7].to_i)
  end

  def self.by_month(date)
    # Receives a DateTime object, returns Orders for all the month
    # dt = DateTime.new(2014,12,1) 
    # Order.payable_by_date_month(dt)
    date_start = date.beginning_of_month
    date_end = date.end_of_month
    where("payable_at >= ? and payable_at <= ?", date_start, date_end)
  end

  def self.by_month_count(date)
    self.by_month(date).count
  end

  def self.by_month_amount(date)
    self.by_month(date).sum(:amount) / 100.0
  end

  def self.by_parent_month(parent_id, date=DateTime.now)
    date_start = date.beginning_of_month
    date_end = date.end_of_month
    where(parent_id: parent_id, payable_at: (date_start..date_end)).limit(1)[0]
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
    "https://podemos.info/participa/colaboraciones/colabora/"
  end

  # USAMOS reference
  #def concept
    # COMPROBACIÓN  Es el texto que aparecefrá en el recibo. Sera "Colaboracion "mes x"
    # TODO comprobación / concepto
  #  "Colaboración mes de XXXX"
  #end



  def mark_as_payed_on!(date)
    self.status = 2 
    self.payed_at = date
    self.save
  end



  #### REDSYS CC PAYMENTS ####

  def redsys_secret(key)
    Rails.application.secrets.redsys[key]
  end

  def redsys_identifier
    if not self.first or self.redsys_response
      self.payment_identifier
    else
      redsys_secret "identifier"
    end
  end

  def redsys_expiration
    Date.strptime self.redsys_response["Ds_ExpiryDate"], "%y%m" if self.redsys_response
  end

  def redsys_order_id
    @order_id ||= 
      if self.redsys_response
        self.redsys_response["Ds_Order"]
      else
        if self.persisted?
          self.id.to_s.rjust(16, "0")
        else
          self.parent.id.to_s.rjust(7, "0") + Order::PARENT_CLASSES[parent.class] + Time.now.to_i.to_s(36)[-4..-1]
        end
      end
  end
    
  def redsys_post_url
    redsys_secret "post_url"
  end

  def redsys_merchant_message
    if self.redsys_response
      "#{self.amount}#{self.redsys_order_id}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_response['Ds_Response']}#{self.redsys_secret "secret_key"}"
    elsif self.first
      "#{self.amount}#{self.redsys_order_id}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_secret "transaction_type"}#{self.redsys_merchant_url}#{self.redsys_secret "identifier"}#{self.redsys_secret "secret_key"}"
    else
      "#{self.amount}#{self.redsys_order_id}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_secret "transaction_type"}#{self.redsys_merchant_url}#{self.redsys_identifier}true#{self.redsys_secret "secret_key"}"   
    end
  end

  def redsys_merchant_url
    orders_callback_redsys_url(protocol: if Rails.env.development? then :http else :https end, redsys_order_id: self.redsys_order_id, parent_id: self.parent.id,   user_id: self.user.id) 
  end

  def redsys_merchant_signature
    Digest::SHA1.hexdigest(self.redsys_merchant_message).upcase
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
    redsys_logger.info("User: #{self.user.id} - #{self.parent.class.to_s}: #{self.parent.id}")
    redsys_logger.info("Data: #{self.attributes.inspect}")
    redsys_logger.info("Params: #{params}")
    self.payment_response = params.to_json

    payment_date = Time.strptime params["Ds_Date"] + " " + params["Ds_Hour"], "%d/%m/%Y %H:%M"
    if (payment_date-1.hours) < Time.now and Time.now < (payment_date+1.hours) and params["Ds_Response"].to_i < 100 and params["user_id"].to_i == self.user_id and params["Ds_Signature"] == self.redsys_merchant_signature
      redsys_logger.info("Status: OK")
      self.status = 2
      self.payed_at = Time.now
      self.payment_identifier = params["Ds_Merchant_Identifier"] if self.first
    else
      redsys_logger.info("Status: KO - ERROR")
      self.status = 3
    end

    transaction do
      self.save
      if self.parent
        self.parent.payment_processed self
      end
    end
  end

  def redsys_params
    extra = if self.first 
            {
              "Ds_Merchant_UrlOK"             => self.parent.ok_url,
              "Ds_Merchant_UrlKO"             => self.parent.ko_url
            }
            else
            {
              'Ds_Merchant_DirectPayment'     => 'true'
            }
            end

    {
      "Ds_Merchant_Currency"          => self.redsys_secret("currency"),
      "Ds_Merchant_MerchantCode"      => self.redsys_secret("code"),
      "Ds_Merchant_MerchantName"      => self.redsys_secret("name"),
      "Ds_Merchant_Terminal"          => self.redsys_secret("terminal"),
      "Ds_Merchant_TransactionType"   => self.redsys_secret("transaction_type"),
      "Ds_Merchant_MerchantData"      => self.redsys_secret("data"),
      "Ds_Merchant_PayMethods"        => self.redsys_secret("payment_methods"),
      "Ds_Merchant_MerchantURL"       => self.redsys_merchant_url,
      "Ds_Merchant_Identifier"        => self.redsys_identifier,
      "Ds_Merchant_Order"             => self.redsys_order_id,
      "Ds_Merchant_Amount"            => self.amount,
      "Ds_Merchant_MerchantSignature" => self.redsys_merchant_signature
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

    http.post uri, URI.encode_www_form(self.redsys_params)
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
