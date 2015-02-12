class Collaboration < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  acts_as_paranoid
  has_paper_trail

  belongs_to :user
  has_many :order, as: :parent

  validates :user_id, :amount, :frequency, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true
  validates :user_id, uniqueness: true
  validate :validates_not_passport
  validate :validates_age_over

  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, numericality: true, if: :is_bank_national?
  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, presence: true, if: :is_bank_national?
  validate :validates_ccc, if: :is_bank_national?

  validates :iban_account, :iban_bic, presence: true, if: :is_bank_international?
  validate :validates_iban, if: :is_bank_international?

  AMOUNTS = {"5 €" => 500, "10 €" => 1000, "20 €" => 2000, "30 €" => 3000, "50 €" => 5000}
  FREQUENCIES = {"Mensual" => 1, "Trimestral" => 3, "Anual" => 12}
  STATUS = {"Sin pago" => 0, "Error" => 1, "Sin confirmar" => 2, "OK" => 3, "Alerta" => 4}

  scope :credit_cards, -> {where(payment_type: 1)}
  scope :banks, -> {where(payment_type: [2,3])}
  scope :bank_nationals, -> {where(payment_type: 2)}
  scope :bank_internationals, -> {where(payment_type: 3)}
  scope :frequency_month, -> {where(frequency: 1)}
  scope :frequency_quarterly, -> {where(frequency: 3)}
  scope :frequency_anual, -> {where(frequency: 12)}
  scope :amount_1, -> {where("amount < 10")}
  scope :amount_2, -> {where("amount > 10 and amount < 20")}
  scope :amount_3, -> {where("amount > 20")}

  after_create :set_initial_status

  def last_order
    self.order.last
  end

  def set_initial_status
    self.status=0
  end

  def set_active
    self.status=2 if self.status < 2
    self.save
  end

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
    Order::PAYMENT_TYPES.invert[self.payment_type]
    # TODO
  end

  def frequency_name
    Collaboration::FREQUENCIES.invert[self.frequency]
  end

  def status_name
    Collaboration::STATUS.invert[self.status]
  end

  def ccc_full 
    "#{"%04d" % ccc_entity} #{"%04d" % ccc_office} #{"%02d" % ccc_dc} #{"%010d" % ccc_account}"
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def upcoming_payments
    now = DateTime.now
    payments = []
    payments << if self.is_credit_card?
                  now
                elsif now.day < Order.creation_day 
                  now.change day: Order.creation_day
                else
                  (now + 1.month).change day: Order.creation_day
                end

    while payments.length < 12/self.frequency
      payments << (payments[-1] + self.frequency.months)
    end

    payments
  end

  def is_recurrent?
    true
  end

  def is_valid?
    self.status>1
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def create_order date, first=false
    order = Order.new do |o|
      o.user = self.user
      o.parent = self
      o.reference = "Colaboración mes de " + I18n.localize(date, :format => "%B")
      o.first = first or self.status==0
      o.amount = self.amount
      o.payable_at = date
      o.payment_type = self.payment_type
      o.payment_identifier = self.payment_identifier
    end
    order
  end

  def payment_identifier
    if self.is_credit_card?
      self.redsys_identifier
    elsif self.is_bank_national?
      "#{self.iban_account}/#{self.iban_bic}"
    elsif self.is_bank_international?
      self.ccc_full
    end
  end

  def payment_processed order
    if order.is_paid?
      if order.has_warnings?
        self.status = 4
      else
        self.status = 3
      end

      if self.is_credit_card?
        self.redsys_identifier = order.payment_identifier
        self.redsys_expiration = order.redsys_expiration
      end
    else
      self.status = 1
    end
    self.save
  end

  def set_warning
    self.status = 4
    self.save
  end

  def generate_order(date=DateTime.now)
    collaboration_start = self.created_at
    if date < collaboration_start
      false
    else 
      if ((date.year*12+date.month) - (collaboration_start.year*12+collaboration_start.month) - (date.day >= collaboration_start.day ? 0 : 1)) % self.frequency == 0
        order = Order.month(date).parent(self)[0]
        if not order 
          order = Collaboration.create_order date, false
        end
        order
      else
        nil
      end
    end
  end

  def ok_url
    ok_collaboration_url
  end

  def ko_url
    ko_collaboration_url
  end
end
