class Collaboration < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :user

  validates :user_id, :amount, :frequency, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true
  validates :user_id, uniqueness: true
  validate :validates_not_passport
  validate :validates_age_over

  validates :redsys_order, uniqueness: true, if: :is_credit_card?
  validates :redsys_order, presence: true, if: :is_credit_card?

  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, numericality: true, if: :is_bank_national?
  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, presence: true, if: :is_bank_national?
  validate :validates_ccc, if: :is_bank_national?

  validates :iban_account, :iban_bic, presence: true, if: :is_bank_international?
  validate :validates_iban, if: :is_bank_international?

  before_validation(on: :create) do
    self.update_attribute(:redsys_order, redsys_generate_order) if self.is_credit_card?
  end

  AMOUNTS = [["5 €", 500], ["10 €", 1000], ["20 €", 2000], ["30 €", 3000], ["50 €", 5000]]
  FREQUENCIES = [["Mensual", 1], ["Trimestral", 3], ["Anual", 12]]
  TYPES = [
    ["Suscripción con Tarjeta de Crédito/Débito", 1], 
    ["Domiciliación en cuenta bancaria (CCC)", 2], 
    ["Domiciliación en cuenta extranjera (IBAN)", 3], 
  ]

  scope :credit_cards, -> {where(payment_type: 1)}
  scope :bank_nationals, -> {where(payment_type: 2)}
  scope :bank_internationals, -> {where(payment_type: 3)}
  scope :frequency_month, -> {where(frequency: 1)}
  scope :frequency_quarterly, -> {where(frequency: 3)}
  scope :frequency_anual, -> {where(frequency: 12)}
  scope :amount_1, -> {where("amount < 10")}
  scope :amount_2, -> {where("amount > 10 and amount < 20")}
  scope :amount_3, -> {where("amount > 20")}

  def validates_not_passport
    if self.user.is_passport? 
      self.errors.add(:user, "No puedes colaborar si eres extranjero.")
    end
  end

  def validates_age_over
    if self.user.born_at > Date.today-18.years
      self.errors.add(:user, "No puedes colaborar si eres menor de edad.")
    end
  end

  def validates_ccc 
    if self.ccc_entity and self.ccc_office and self.ccc_dc and self.ccc_account
      unless BankCccValidator.validate("#{self.ccc_full}")
        self.errors.add(:ccc_dc, "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
      end
    end
  end

  def validates_iban
    unless IBANTools::IBAN.valid?(self.iban_account)
      self.errors.add(:iban_account, "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
    end
  end

  def is_credit_card?
    self.payment_type == 1
  end

  def is_bank_national?
    self.payment_type == 2
  end

  def is_bank_international?
    self.payment_type == 3
  end

  def payment_type_name
    Collaboration::TYPES.select{|v| v[1] == self.payment_type }[0][0]
    # TODO
  end

  def frequency_name
    Collaboration::FREQUENCIES.select{|v| v[1] == self.frequency }[0][0]
  end

  def ccc_full 
    "#{"%04d" % ccc_entity} #{"%04d" % ccc_office} #{"%02d" % ccc_dc} #{"%010d" % ccc_account}"
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def frequency_payments
    case self.frequency
    when 1 
      12
    when 3
      4
    when 12
      1
    end
  end

  def redsys_secret(key)
    Rails.application.secrets.redsys[key]
  end

  def identifier
    if self.redsys_response
      JSON.parse(self.redsys_response)["Ds_Merchant_Identifier"]
    else
      redsys_secret "identifier"
    end
  end

  def redsys_merchant_url(type=nil)
    redsys_callback_collaboration_url(protocol: :https, redsys_order: self.redsys_order, collaboration_id: self.id, user_id: self.user.id, type: type) 
  end

  def redsys_merchant_message
    "#{self.amount}#{self.redsys_order}#{self.redsys_secret "code"}#{self.redsys_secret "currency"}#{self.redsys_secret "transaction_type"}#{self.redsys_merchant_url}#{self.redsys_secret "identifier"}#{self.redsys_secret "secret_key"}"
  end

  def redsys_merchant_signature
    Digest::SHA1.hexdigest(self.redsys_merchant_message).upcase
  end

  def redsys_match_signature? signature
    signature == self.redsys_merchant_signature
  end

  def confirm!
    self.update_attribute(:response_status, "OK")
  end

  def redsys_logger
    @@redsys_logger ||= Logger.new("#{Rails.root}/log/collaborations_redsys.log")
  end

  def redsys_parse_response! params
    redsys_logger.info("*" * 40)
    redsys_logger.info("Redsys: New collaboration")
    redsys_logger.info("User: #{self.user.id} - Collaboration: #{self.id}")
    redsys_logger.info("Data: #{self.attributes.inspect}")
    redsys_logger.info("Params: #{params}")
    self.update_attribute(:redsys_response, params.to_json)
    self.update_attribute(:redsys_response_code, params["Ds_Response"])
    self.update_attribute(:redsys_response_recieved_at, DateTime.now)

    # TODO check if Date/Time is correct 
    if params["Ds_Response"].to_i < 100 and params["collaboration_id"].to_i == self.id and params["user_id"].to_i == self.user.id # and self.redsys_match_signature?(params["Ds_Signature"])
      redsys_logger.info("Status: OK")
      self.confirm!
    else
      redsys_logger.info("Status: KO - ERROR")
      self.update_attribute(:response_status, "KO")
    end
  end

  def is_valid?
    # TODO:  def redsys_is_valid? 
    # TODO response_status for bank national/international
    self.response_status == "OK"
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def generate_order(date=DateTime.now)
    collaboration_start = self.created_at
    if date < collaboration_start
      false
    else 
      if ((date.year*12+date.month) - (collaboration_start.year*12+collaboration_start.month) - (date.day >= collaboration_start.day ? 0 : 1)) % self.frequency == 0
        order = Order.by_collaboration_month(self, date)
        if not order 
          order = Order.create(collaboration: self, payable_at: date)
        end
        order
      else
        nil
      end
    end
  end

  def params
    {
      "Ds_Merchant_Currency"          => self.redsys_secret("currency"),
      "Ds_Merchant_MerchantCode"      => self.redsys_secret("code"),
      "Ds_Merchant_MerchantName"      => self.redsys_secret("name"),
      "Ds_Merchant_Terminal"          => self.redsys_secret("terminal"),
      "Ds_Merchant_TransactionType"   => self.redsys_secret("transaction_type"),
      "Ds_Merchant_MerchantData"      => self.redsys_secret("data"),
      "Ds_Merchant_PayMethods"        => self.redsys_secret("payment_methods"),
      "Ds_Merchant_Identifier"        => self.identifier,
      "Ds_Merchant_Order"             => self.redsys_order,
      "Ds_Merchant_Amount"            => self.amount,
      "Ds_Merchant_MerchantURL"       => self.redsys_merchant_url,
      "Ds_Merchant_MerchantUrlOK"     => self.redsys_merchant_url("ok"),
      "Ds_Merchant_MerchantUrlKO"     => self.redsys_merchant_url("ko"),
      "Ds_Merchant_MerchantSignature" => self.redsys_merchant_signature
    }
  end
  
  private 

  def redsys_set_order
    self.update_attribute(:redsys_order, redsys_generate_order)
  end

  def redsys_generate_order
    # Redsys requires an order_id be provided with each transaction of a
    # specific format. The rules are as follows:
    #
    # * Minimum length: 4
    # * Maximum length: 12
    # * First 4 digits must be numerical
    # * Remaining 8 digits may be alphanumeric
    rand(0..9999).to_s + SecureRandom.hex.to_s[0..7]
    #1234567890
  end

end
