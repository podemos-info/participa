class Collaboration < ActiveRecord::Base
  belongs_to :user
  validates :user, :amount, :frequency, :order, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true
  validates :order, uniqueness: true
  validates :user, uniqueness: true

  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, numericality: true, if: :is_bank_national?

  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, presence: true, if: :is_bank_national?
  validates :iban_account, :iban_bic, presence: true, if: :is_bank_international?

  validate :validate_ccc, if: :is_bank_national?, message: "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala."
  validate :validate_iban, if: :is_bank_international?, message: "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala."

  before_validation :set_order

  acts_as_paranoid

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

  def validate_ccc 
    BankCccValidator.validate("#{self.ccc_full}")
  end

  def validate_iban
    IBANTools::IBAN.valid?(self.iban_account)
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

  def ccc_full 
    "#{ccc_entity} #{ccc_office} #{ccc_dc} #{ccc_account}"
  end

  def merchant_currency
    978
  end

  def merchant_code
    Rails.application.secrets.redsys["code"]
  end

  def merchant_terminal
    Rails.application.secrets.redsys["terminal"]
  end

  def redsys_secret_key
    Rails.application.secrets.redsys["secret_key"]
  end

  def merchant_url 
    Rails.application.secrets.redsys["merchant_url"]
  end

  def merchant_transaction_type
    5
  end

  def merchant_date_frequency
    30
  end
  
  def merchant_sumtotal
    self.amount * self.frequency
  end

  def merchant_message
    #"#{self.amount}#{self.order}#{self.merchant_code}#{self.merchant_currency}#{self.merchant_transaction_type}#{self.merchant_url}#{self.redsys_secret_key}"
    #Digest=SHA-1(Ds_Merchant_Amount + Ds_Merchant_Order +Ds_Merchant_MerchantCode + DS_Merchant_Currency + Ds_Merchant_SumTotal + CLAVE SECRETA))
    "#{self.amount}#{self.order}#{self.merchant_code}#{self.merchant_currency}#{self.merchant_sumtotal}#{self.redsys_secret_key}"
  end

  def merchant_signature
    Digest::SHA1.hexdigest(self.merchant_message).upcase
  end

  def match_signature signature
    # FIXME: check SHA1 signature form redsys
    # signature == merchant_signature
  end

  def parse_response params
    self.update_attribute(:response, params.to_json)
    self.update_attribute(:response_code, params["Ds_Response"])
    self.update_attribute(:response_recieved_at, DateTime.now)
    if params["Ds_Response"] == "0000" #TODO and match_signature(params["Ds_Signature"])
      self.update_attribute(:response_status, "OK")
    else
      self.update_attribute(:response_status, "KO")
    end
  end

  def is_valid?
    self.response_status == "OK"
  end

  private 

  def set_order
    self.update_attribute(:order, generate_order)
  end

  def generate_order
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
