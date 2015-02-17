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
  scope :bank_nationals, -> {where(payment_type: 2)}
  scope :bank_internationals, -> {where(payment_type: 3)}
  scope :frequency_month, -> {where(frequency: 1)}
  scope :frequency_quarterly, -> {where(frequency: 3)}
  scope :frequency_anual, -> {where(frequency: 12)}
  scope :amount_1, -> {where("amount < 10")}
  scope :amount_2, -> {where("amount > 10 and amount < 20")}
  scope :amount_3, -> {where("amount > 20")}


  after_create :set_initial_status

  def set_initial_status
    self.status = 0
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
    "#{"%04d" % ccc_entity}#{"%04d" % ccc_office}#{"%02d" % ccc_dc}#{"%010d" % ccc_account}"
  end

  def admin_permalink
    admin_collaboration_path(self)
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

  def first_order
    @first_order = self.order.order(payable_at: :asc).first if not defined? @first_order
    @first_order
  end

  def create_order date, maybe_first=false
    is_first = false
    if maybe_first
      if self.first_order.nil?
        is_first = true
      elsif self.first_order.payable_at.unique_month==date.unique_month
        return self.first_order
      end
    end

    order = Order.new do |o|
      o.user = self.user
      o.parent = self
      o.reference = "Colaboración mes de " + I18n.localize(date, :format => "%B")
      o.first = is_first
      o.amount = self.amount*self.frequency

      date = date.change(day: Order.payment_day) if not (is_first and self.is_credit_card?)
      o.payable_at = date
      o.payment_type = self.payment_type
      o.payment_identifier = self.payment_identifier
    end
    @first_order = order if is_first
    order
  end

  def payment_identifier
    if self.is_credit_card?
      self.redsys_identifier
    elsif self.is_bank_national?
      self.ccc_full
    elsif self.is_bank_international?
      "#{self.iban_account}/#{self.iban_bic}"
    end
  end

  def payment_processed order
    if order.is_paid?
      if order.has_warnings?
        self.status = 4
      else
        self.status = 3
      end

      if self.is_credit_card? and order.first
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

  def must_have_order? date
    if self.first_order.nil?
      first_month = Date.today.unique_month
      first_month += 1 if not self.is_credit_card? and self.created_at.unique_month==first_month
    else
      first_month = self.first_order.payable_at.unique_month
    end

    (first_month <= date.unique_month) and ((date.unique_month - first_month) % self.frequency) == 0
  end

  def get_orders date_start=Date.today, date_end=Date.today
    saved_orders = Hash.new {|h,k| h[k] = [] }

    self.order.by_parent(self).by_date(date_start, date_end).each do |o|
      saved_orders[o.payable_at.unique_month] << o
    end

    current = date_start

    orders = []

    while current<=date_end
      # Check last saved order for this month
      month_orders = saved_orders[current.unique_month]
      order = month_orders[-1]

      # if don't have a saved order, create it (not persistent)
      if self.deleted_at.nil? and ((not order and self.must_have_order? current) or (order and order.has_errors?))
        order = create_order current, (saved_orders.empty? and orders.empty?)
        month_orders << order if order
      end

      orders << month_orders if month_orders.length>0
      current += 1.month
    end
    orders
  end

  def ok_url
    ok_collaboration_url
  end

  def ko_url
    ko_collaboration_url
  end

  def charge
    order = self.get_orders[0]
    if order and order.is_payable?
      if self.is_credit_card?
        order.redsys_send_request 
      else
        order.save
      end
    end
  end
end
