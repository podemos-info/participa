class Order < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :parent, -> { with_deleted }, polymorphic: true
  belongs_to :collaboration, -> { with_deleted.joins(:order).where(orders: {parent_type: 'Collaboration'}) }, foreign_key: 'parent_id'
  belongs_to :user, -> { with_deleted }

  attr_accessor :raw_xml
  validates :payment_type, :amount, :payable_at, presence: true

  STATUS = {"Nueva" => 0, "Sin confirmar" => 1, "OK" => 2, "Alerta" => 3, "Error" => 4, "Devuelta" => 5}
  PAYMENT_TYPES = {
    "Suscripción con Tarjeta de Crédito/Débito" => 1, 
    "Domiciliación en cuenta bancaria (formato CCC)" => 2, 
    "Domiciliación en cuenta bancaria (formato IBAN)" => 3 
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

  def is_chargeable?
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

  def payment_type_name
    Order::PAYMENT_TYPES.invert[self.payment_type]
  end

  def is_credit_card?
    self.payment_type == 1
  end

  def is_bank?
    self.payment_type != 1
  end

  def is_bank_national?
    self.is_bank? and !self.is_bank_international?
  end

  def is_bank_international?
    self.has_iban_account? and !self.payment_identifier.start_with("ES")
  end

  def has_ccc_account?
    self.payment_type==2
  end

  def has_iban_account?
    self.payment_type==3
  end

  def error_message
    if self.payment_type == 1
      return self.redsys_text_status
    else
      return self.bank_text_status
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
      self.parent.payment_processed! self
    end 
  end

  def mark_as_returned! code=nil
    self.payment_response = code if code
    self.status = 5
    if self.save
      if self.parent and not self.parent.deleted?
        reason = SEPA_RETURNED_REASONS[self.payment_response]
        if reason
          self.parent.returned_order! reason[:error], reason[:warn]
        else
          self.parent.returned_order!
        end
      end
      true
    else
      false
    end
  end

  def self.mark_bank_orders_as_charged!(date=Date.today)
    Order.banks.by_date(date, date).to_be_charged.update_all(status:1)
  end
  
  def self.mark_bank_orders_as_paid!(date=Date.today)
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    Order.banks.by_date(date, date).charging.update_all(status:2, payed_at: date)
  end

  SEPA_RETURNED_REASONS = {
    "AC01" => { error: true, warn: true, text: "El IBAN o BIN son incorrectos."},
    "AC04" => { error: true, text: "La cuenta ha sido cerrada."},
    "AC06" => { error: true, text: "Cuenta bloqueada."},
    "AC13" => { error: true, warn: true, text: "Cuenta de cliente no apta para operaciones entre comercios."},
    "AG01" => { error: true, text: "Cuenta de ahorro, no admite recibos."},
    "AG02" => { error: false, warn: true, text: "Código de pago incorrecto (ejemplo: RCUR sin FRST previo)."},
    "AM04" => { error: false, text: "Fondos insuficientes."},
    "AM05" => { error: false, warn: true, text: "Orden duplicada (ID repetido o dos operaciones FRST)."},
    "BE01" => { error: true, text: "El nombre dado no coincide con el titular de la cuenta."},
    "BE05" => { error: false, text: "Creditor Identifier incorrecto."},
    "FF01" => { error: false, warn: true, text: "Código de transacción incorrecto o formato de fichero inválido."},
    "FF05" => { error: false, warn: true, text: "Tipo de 'Direct Debit' incorrecto."},
    "MD01" => { error: false, text: "Transacción no autorizada."},
    "MD02" => { error: false, text: "Información del cliente incompleta o incorrecta."},
    "MD06" => { error: false, text: "El cliente reclama no haber autorizado esta orden (hasta 8 semanas de plazo)."},
    "MD07" => { error: true, text: "El titular de la cuenta ha muerto."},
    "MS02" => { error: false, text: "El cliente ha devuelto esta orden."},
    "MS03" => { error: false, text: "Razón no especificada por el banco."},
    "RC01" => { error: true, warn: true, text: "El código BIC provisto es incorrecto."},
    "RR01" => { error: true, warn: true, text: "La identificación del titular de la cuenta requerida legalmente es insuficiente o inexistente."},
    "RR02" => { error: true, warn: true, text: "El nombre o la dirección del cliente requerida legalmente es insuficiente o inexistente."},
    "RR03" => { error: false, warn: true, text: "El nombre o la dirección del cliente requerida legalmente es insuficiente o inexistente."},
    "RR04" => { error: true, warn: true, text: "Motivos legales. Contactar al banco para más información."},
    "SL01" => { error: true, text: "Cobro bloqueado a entidad por lista negra o ausencia en lista de cobros autorizados."}
  }

  def bank_text_status
    case self.status
    when 4
      "Error"
    when 5
      if self.payment_response
        if SEPA_RETURNED_REASONS[self.payment_response]
          "#{self.payment_response}: #{SEPA_RETURNED_REASONS[self.payment_response][:text]}"
        else
          "#{self.payment_response}"
        end
      else
        "Orden devuelta"
      end
    else
      ""
    end
  end

  #### REDSYS CC PAYMENTS ####

  def redsys_secret(key)
    Rails.application.secrets.redsys[key]
  end

  def redsys_expiration
    # Credit card is valid until the last day of expiration month
    DateTime.strptime(self.redsys_response["Ds_ExpiryDate"], "%y%m") + 1.month - 1.seconds if self.redsys_response and self.first
  end

  def redsys_order_id
    @order_id ||= 
      if self.redsys_response and self.first
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
    self.sign(self.redsys_order_id, self.redsys_merchant_params)
  end

  def redsys_merchant_response_signature
    request_start = self.raw_xml.index "<Request"
    request_end = self.raw_xml.index "</Request>", request_start if request_start
    msg = self.raw_xml[request_start..request_end+9] if request_start and request_end
    self.sign(self.redsys_order_id, msg)
  end
  
  def redsys_logger
    @@redsys_logger ||= Logger.new("#{Rails.root}/log/redsys.log")
  end

  def redsys_response
    @redsys_response ||= if self.payment_response.nil? then nil else JSON.parse(self.payment_response) end
  end

  def redsys_parse_response! params, xml = nil
    redsys_logger.info("*" * 40)
    redsys_logger.info("Redsys: New payment")
    redsys_logger.info("User: #{self.user_id} - #{self.parent.class.to_s}: #{self.parent.id}")
    redsys_logger.info("Data: #{self.attributes.inspect}")
    redsys_logger.info("Params: #{params}")
    redsys_logger.info("XML: #{xml}")
    self.payment_response = params.to_json
    self.raw_xml = xml

    if params["Ds_Response"].to_i < 100
      self.payed_at = Time.now
      begin
        payment_date = REDSYS_SERVER_TIME_ZONE.parse "#{params["Fecha"] or params["Ds_Date"]} #{params["Hora"] or params["Ds_Hour"]}"
        redsys_logger.info("Validation data: #{payment_date}, #{Time.now}, #{params["user_id"]}, #{self.user_id}, #{params["Ds_Signature"]}, #{self.redsys_merchant_response_signature}")
        if (payment_date-1.hours) < Time.now and Time.now < (payment_date+1.hours) and params["Ds_Signature"] == self.redsys_merchant_response_signature #and params["user_id"].to_i == self.user_id
          redsys_logger.info("Status: OK")
          self.status = 2
        else
          redsys_logger.info("Status: OK, but with warnings ")
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
      self.parent.payment_processed! self
    end    
  end

  def redsys_raw_params
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

    Hash[{
      "Ds_Merchant_Amount"            => self.amount.to_s,
      "Ds_Merchant_Currency"          => self.redsys_secret("currency"),
      "Ds_Merchant_MerchantCode"      => self.redsys_secret("code"),
      "Ds_Merchant_MerchantName"      => self.redsys_secret("name"),
      "Ds_Merchant_Terminal"          => self.redsys_secret("terminal"),
      "Ds_Merchant_TransactionType"   => self.redsys_secret("transaction_type"),
      "Ds_Merchant_PayMethods"        => self.redsys_secret("payment_methods"),
      "Ds_Merchant_MerchantData"      => self.user_id.to_s,
      "Ds_Merchant_MerchantURL"       => self.redsys_merchant_url,
      "Ds_Merchant_Order"             => self.redsys_order_id
    }.merge(extra).map{|k,v| [k.upcase, v]}]

  end

  def redsys_merchant_params
    Base64.strict_encode64(redsys_raw_params.to_json)
  end

  def redsys_params
    {
      'Ds_SignatureVersion' => "HMAC_SHA256_V1",
      'Ds_MerchantParameters' => redsys_merchant_params,
      'Ds_Signature' => self.redsys_merchant_request_signature
    }
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
      self.parent.payment_processed! self
    end
  end

  def redsys_text_status
    case self.status
    when 5
      "Orden devuelta"
    else
      code =  if self.redsys_response 
                if self.first
                  self.redsys_response["Ds_Response"]
                else
                  self.redsys_response[-1]
                end
              else
                nil
              end

      if code
        code = code.to_i if code.is_a? String and not code.start_with? "SIS"
          # Given a status code, returns the status message
        message = case code
          when "SIS0298"  then "El comercio no permite realizar operaciones de Tarjeta en Archivo."
          when "SIS0319"  then "El comercio no pertenece al grupo especificado en Ds_Merchant_Group."
          when "SIS0321"  then "La referencia indicada en Ds_Merchant_Identifier no está asociada al comercio."
          when "SIS0322"  then "Error de formato en Ds_Merchant_Group."
          when "SIS0325"  then "Se ha pedido no mostrar pantallas pero no se ha enviado ninguna referencia de tarjeta."
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
        "#{code}: #{message}"
      else
        "Transacción no procesada"
      end
    end
  end

  def redsys_callback_response
    response = "<Response Ds_Version='0.0'><Ds_Response_Merchant>#{self.is_paid? ? "OK" : "KO" }</Ds_Response_Merchant></Response>"
    signature = self._sign(self.redsys_order_id, response)

    soap = []
    soap << <<-EOL
<?xml version='1.0' encoding='UTF-8'?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<SOAP-ENV:Body>
<ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<return xsi:type="xsd:string">
EOL
    soap[-1].rstrip!
    soap << CGI.escapeHTML("<Message>#{response}<Signature>#{signature}</Signature></Message>")
    soap << "</return>\n</ns1:procesaNotificacionSIS>\n</SOAP-ENV:Body>\n</SOAP-ENV:Envelope>"

    soap.join
  end

private

  def _sign key, data
    des3 = OpenSSL::Cipher::Cipher.new('des-ede3-cbc')
    des3.encrypt
    des3.key = Base64.strict_decode64(self.redsys_secret("secret_key"))
    des3.iv = "\0"*8
    des3.padding = 0

    _key = key
    _key += "\0" until data.bytesize % 8 == 0
    key = des3.update(_key) + des3.final
    digest = OpenSSL::Digest.new('sha256')
    Base64.strict_encode64(OpenSSL::HMAC.digest(digest, key, data))
  end
end
