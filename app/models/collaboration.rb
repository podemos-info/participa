# frozen_string_literal: true

require 'fileutils'

# Collaboration class
class Collaboration < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  before_update :check_frequency,
                if: ->(collaboration) { collaboration.type_amount == 'single' }
  acts_as_paranoid
  has_paper_trail

  belongs_to :user, -> { with_deleted }

  # FIXME: this should be orders for the inflextions
  # http://guides.rubyonrails.org/association_basics.html#the-has-many-association
  # should have a solid test base before doing this change and review where .order
  # is called.
  #
  # has_many :orders, as: :parent
  has_many :order, as: :parent

  attr_accessor :skip_queries_validations
  validates :payment_type, :amount, :type_amount, presence: true
  validates :frequency,
            presence: true,
            if: ->(collaboration) { collaboration.type_amount == :recursive }
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true
  validates :user_id,
            uniqueness: { scope: :deleted_at },
            allow_nil: true,
            allow_blank: true,
            unless: :skip_queries_validations
  validates :non_user_email,
            uniqueness: { case_sensitive: false, scope: :deleted_at },
            allow_nil: true,
            allow_blank: true,
            unless: :skip_queries_validations
  validates :non_user_document_vatid,
            uniqueness: { case_sensitive: false, scope: :deleted_at },
            allow_nil: true,
            allow_blank: true,
            unless: :skip_queries_validations
  validates :non_user_email,
            :non_user_document_vatid,
            :non_user_data,
            presence: true,
            if: proc { |c| c.user.nil? }

  validate :validates_not_passport
  validate :validates_age_over
  validate :validates_has_user

  validates :ccc_entity,
            :ccc_office,
            :ccc_dc,
            :ccc_account,
            numericality: true,
            if: :has_ccc_account?
  validates :ccc_entity,
            :ccc_office,
            :ccc_dc,
            :ccc_account,
            presence: true,
            if: :has_ccc_account?
  validate :validates_ccc, if: :has_ccc_account?

  validates :iban_account, :iban_bic, presence: true, if: :has_iban_account?
  validate :validates_iban, if: :has_iban_account?

  enum type_amount: %i[single recursive]
  # TYPE_AMOUNT = {"Mensual" => 1, "Puntual" => 0}

  attr_accessor :amount_collector
  attr_accessor :amount_holder
  AMOUNTS = {
    'Personalizado' => 0,
    '5 €' => 500,
    '10 €' => 1000,
    '20 €' => 2000,
    '30 €' => 3000,
    '50 €' => 5000,
    '100 €' => 10_000,
    '200 €' => 20_000,
    '500 €' => 50_000
  }.freeze
  # FREQUENCIES = {"Mensual" => 1, "Trimestral" => 3, "Anual" => 12}
  STATUS = {
    'Sin pago' => 0,
    'Error' => 1,
    'Sin confirmar' => 2,
    'OK' => 3,
    'Alerta' => 4
  }.freeze

  scope :created, -> { where(deleted_at: nil) }
  scope :credit_cards, -> { created.where(payment_type: 1) }
  scope :banks, -> { created.where.not(payment_type: 1) }

  scope :bank_nationals, lambda {
    created.where.not(payment_type: 1)
           .where.not(
             'collaborations.payment_type = 3 and iban_account NOT LIKE ?',
             'ES%'
           )
  }

  scope :bank_internationals, lambda {
    created.where(payment_type: 3).where('iban_account NOT LIKE ?', 'ES%')
  }

  scope :frequency_month, -> { created.where(frequency: 1) }
  scope :frequency_quarterly, -> { created.where(frequency: 3) }
  scope :frequency_anual, -> { created.where(frequency: 12) }
  scope :amount_1, -> { created.where('amount < 1000') }
  scope :amount_2, -> { created.where('amount >= 1000 and amount < 2000') }
  scope :amount_3, -> { created.where('amount > 2000') }

  scope :incomplete, -> { created.where(status: 0) }
  scope :unconfirmed, -> { created.where(status: 2) }
  scope :active, -> { created.where(status: 3) }
  scope :warnings, -> { created.where(status: 4) }
  scope :errors, -> { created.where(status: 1) }
  scope :suspects, -> { banks.active.where("(select count(*) from orders o where o.parent_id=collaborations.id and o.payable_at>? and o.status=5)>2",Date.today-8.months) }
  scope :legacy, -> { created.where.not(non_user_data: nil) }
  scope :non_user, -> { created.where(user_id: nil) }
  scope :deleted, -> { only_deleted }

  scope :full_view, -> { with_deleted.eager_load(:user).eager_load(:order) }

  scope :autonomy_cc, -> { created.where(for_autonomy_cc: true) }
  scope :town_cc, -> { created.where(for_town_cc: true, for_autonomy_cc: true) }
  scope :island_cc, -> { created.where(for_island_cc: true) }

  after_create :set_initial_status
  before_save :check_spanish_bic

  def set_initial_status
    self.status = 0
  end

  def has_payment?
    status.positive?
  end

  def check_spanish_bic
    self.set_warning! "Marcada como alerta porque el número de cuenta indica un código de entidad inválido o no encontrado en la base de datos de BICs españoles." if [2,3].include? status && is_bank_national? && calculate_bic.nil?
  end

  def validates_not_passport
    errors.add(
      :user, 'No puedes colaborar si no dispones de DNI o NIE.'
    ) if user&.is_passport?
  end

  def validates_age_over
    errors.add(
      :user, 'No puedes colaborar si eres menor de edad.'
    ) if user && user.age <= 18
  end

  def validates_ccc
    if ccc_entity && ccc_office && ccc_dc && ccc_account
      unless BankCccValidator.validate(ccc_full.to_s)
        errors.add(
          :ccc_dc,
          'Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.'
        )
      end
    end
  end

  def validates_iban
    iban_validation = IBANTools::IBAN.valid?(iban_account)
    ccc_validation = iban_account.start_with?('ES') ? BankCccValidator.validate(iban_account[4..-1]) : true
    unless iban_validation && ccc_validation
      errors.add(:iban_account, 'Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.')
    end
  end

  def is_credit_card?
    payment_type == 1
  end

  def is_bank?
    payment_type != 1
  end

  def is_bank_national?
    is_bank? && !is_bank_international?
  end

  def is_bank_international?
    has_iban_account? && !iban_account&.start_with?('ES')
  end

  def has_ccc_account?
    payment_type == 2
  end

  def has_iban_account?
    payment_type == 3
  end

  def payment_type_name
    Order::PAYMENT_TYPES.invert[payment_type]
    # TODO
  end

  def frequency_name
    Collaboration::FREQUENCIES.invert[frequency]
  end

  def status_name
    Collaboration::STATUS.invert[status]
  end

  def ccc_full
    format(
      '%04d%04d%02d%010d',
      ccc_entity,
      ccc_office,
      ccc_dc,
      ccc_account
    ) if ccc_account
  end

  def pretty_ccc_full
    format(
      '%04d %04d %02d %010d',
      ccc_entity,
      ccc_office,
      ccc_dc,
      ccc_account
    ) if ccc_account
  end

  def calculate_iban
    iban = nil
    if ccc_account && (!iban_account || is_bank_national?)
      ccc = ccc_full
      iban = 98 - ("#{ccc}142800".to_i % 97)
      iban = "ES#{iban.to_s.rjust(2, '0')}#{ccc}"
    end
    iban = iban_account.delete(' ') if !iban && iban_account && !iban_account.empty?
    iban
  end

  def calculate_bic
    bic = Podemos::SpanishBIC[ccc_entity] if ccc_account && (!iban_account || is_bank_national?)
    bic = Podemos::SpanishBIC[iban_account[4..7].to_i] if !bic && iban_account && !iban_account.empty? && iban_account[0..1]=="ES"
    bic = iban_bic.delete(' ') if !bic && iban_bic && !iban_bic.empty?
    bic
  end

  def is_recurrent?
    type_amount == :recursive
  end

  def is_payable?
    [2, 3].include?(status) && deleted_at.nil? && valid? && (!user || user.deleted_at.nil?)
  end

  def is_active?
    status > 1 && deleted_at.nil?
  end

  def has_confirmed_payment?
    status > 2 && deleted_at.nil?
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def first_order
    order.sort_by(&:payable_at).detect { |o| o.is_payable? || o.is_paid? }
  end

  def last_order_for(date)
    order.sort_by(&:payable_at).detect { |o| o.payable_at.unique_month <= date.unique_month && (o.is_payable? || o.is_paid?) }
  end

  def create_order(date, maybe_first=false)
    is_first = false
    if maybe_first && !has_confirmed_payment?
      is_first = true if first_order.nil?
      return first_order if first_order&.payable_at&.unique_month == date.unique_month
    end

    date = date.change(day: Order.payment_day) unless is_first && is_credit_card?
    order = Order.new do |o|
      o.user = user
      o.parent = self
      o.reference = 'Donacions ' + I18n.localize(date, format: '%B %Y')
      o.first = is_first
      o.amount = amount
      o.payable_at = date
      o.payment_type = is_credit_card? ? 1 : 3
      o.payment_identifier = payment_identifier
      if for_autonomy_cc && user && !user.vote_autonomy_code.empty?
        o.autonomy_code = user.vote_autonomy_code
        o.town_code = user.vote_town if for_town_cc || for_island_cc
        o.island_code = user.vote_island_code if for_island_cc
      end
    end
    order
  end

  def payment_identifier
    if is_credit_card?
      redsys_identifier
    elsif has_ccc_account?
      "#{calculate_iban}/#{calculate_bic}"
    else
      "#{iban_account}/#{iban_bic}"
    end
  end

  def payment_processed!(order)
    if order.is_paid?
      if order.has_warnings?
        set_warning! 'Marcada como alerta porque se han producido alertas al procesar el pago.'
      else
        set_ok!
      end

      if is_credit_card? && order.first
        update_attributes redsys_identifier: order.payment_identifier, redsys_expiration: order.redsys_expiration
      end
    elsif has_payment?
      set_error! 'Marcada como error porque se ha producido un error al procesar el pago.'
    end
  end

  MAX_RETURNED_ORDERS = 2
  def returned_order!(error=nil, warn=false)
    # FIXME: this should be orders for the inflextions
    # http://guides.rubyonrails.org/association_basics.html#the-has-many-association
    # should have a solid test base before doing this change and review where .order
    # is called.

    if is_payable?
      if error
        set_error! 'Marcada como error porque se ha devuelto una orden con código asociado a error en la colaboración.'
      elsif warn
        set_warning! 'Marcada como alerta porque se ha devuelto una orden con código asociado a alerta en la colaboración.'
      elsif order.count >= MAX_RETURNED_ORDERS
        last_order = last_order_for(Date.today)
        if last_order
          last_month = last_order.payable_at.unique_month
        else
          last_month = created_at.unique_month
        end
        set_error! 'Marcada como error porque se ha superado el límite de órdenes devueltas consecutivas.' if Date.today.unique_month - 1 - last_month >= frequency * MAX_RETURNED_ORDERS
      end
    end
  end

  def has_warnings?
    status == 4
  end

  def has_errors?
    status == 1
  end

  def set_error! reason
    update_attribute :status, 1
    add_comment reason
  end

  def set_active!
    update_attribute(:status, 2) if status < 2
  end

  def set_ok!
    update_attribute :status, 3
  end

  def set_warning! reason
    update_attribute :status, 4
    add_comment reason
  end

  def must_have_order?(date)
    this_month = Date.today.unique_month

    # first order not created yet, must have order this month, or next if its paid by bank and was created this month after payment day
    if first_order.nil?
      next_order = this_month
      next_order += 1 if is_bank? && created_at.unique_month == next_order && created_at.day >= Order.payment_day

    # first order created on asked date
    elsif first_order.payable_at.unique_month == date.unique_month
      return true
    # mustn't have order on months before it first order
    elsif first_order.payable_at.unique_month > date.unique_month
      return false
    # calculate next order month based on last paid order
    elsif frequency
      next_order = last_order_for(date - 1.month).payable_at.unique_month + frequency
      next_order = Date.today.unique_month if next_order < Date.today.unique_month  # update next order when a payment was missed
    else
      return false
    end

    (date.unique_month >= next_order) && ((date.unique_month - next_order) % (frequency || 12)).zero?
  end

  def get_orders(date_start = Date.today, date_end = Date.today, create_orders = true)
    saved_orders = Hash.new {|h,k| h[k] = [] }

    order.select { |o|
      o.payable_at > date_start.beginning_of_month && o.payable_at < date_end.end_of_month
    }.each { |o| saved_orders[o.payable_at.unique_month] << o }

    current = date_start

    orders = []

    while current <= date_end
      # month orders sorted by creation date
      month_orders = saved_orders[current.unique_month].sort_by(&:created_at)

      # valid orders without errors
      valid_orders = month_orders.reject(&:has_errors?)

      # if collaboration is active, should create orders, this month should have an order and it doesn't have a valid saved order, create it (not persistent)
      if deleted_at.nil? && create_orders && must_have_order?(current) && valid_orders.empty?
        order = create_order(current, orders.empty?)
        month_orders << order if order
      end

      orders << month_orders unless month_orders.empty?
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

  def fix_status!
    if !valid? && !has_errors?
      set_error! 'Marcada como error porque la colaboración no supera todas las validaciones antes de generar su orden.'
      true
    else
      false
    end
  end

  def charge!
    if is_payable?
      order = get_orders[0] # get orders for current month
      order = order[-1] if order # get last order for current month
      if order&.is_chargeable?
        order.redsys_send_request if is_active? && is_credit_card?
        order.save unless is_credit_card?
      end
    end
  end

  def get_bank_data(date)
    order = last_order_for date
    if order and order.payable_at.unique_month == date.unique_month and order.is_chargeable?
      col_user = get_user
      ['%02d%02d%06d' % [date.year % 100, date.month, order.id % 1000000],
       col_user.full_name.mb_chars.upcase.to_s,
       col_user.document_vatid.upcase,
       col_user.email,
       col_user.address.mb_chars.upcase.to_s,
       col_user.town_name.mb_chars.upcase.to_s,
       col_user.postal_code,
       col_user.country.upcase,
       calculate_iban,
       ccc_full,
       calculate_bic,
       order.amount / 100,
       order.due_code,
       order.url_source,
       id,
       created_at.strftime('%d-%m-%Y'),
       order.reference,
       order.payable_at.strftime('%d-%m-%Y'),
       frequency_name,
       col_user.full_name.mb_chars.upcase.to_s]
    end
  end

  after_initialize :parse_non_user
  before_save :format_non_user

  class NonUser
    def initialize(args)
      %i[
        country
        document_vatid
        email address
        full_name
        legacy_id
        phone
        postal_code
        province
        town_name
      ].each do |var|
        instance_variable_set("@#{var}", args[var]) if args.member? var
      end
    end

    attr_accessor :address,
                  :country,
                  :document_vatid,
                  :email,
                  :full_name,
                  :legacy_id,
                  :phone,
                  :postal_code,
                  :province,
                  :town_name

    def to_s
      "#{full_name} (#{document_vatid} - #{email})"
    end
  end

  def parse_non_user
    @non_user = non_user_data ? YAML.safe_load(non_user_data, [NonUser]) : nil
  end

  def format_non_user
    if @non_user
      self.non_user_data = YAML.dump(@non_user)
      self.non_user_document_vatid = @non_user.document_vatid
      self.non_user_email = @non_user.email
    else
      self.non_user_data = self.non_user_document_vatid = self.non_user_email = nil
    end
  end

  def set_non_user(info)
    @non_user = info.nil? ? nil : NonUser.new(info)
    format_non_user
  end

  def get_user
    if user
      user
    else
      @non_user
    end
  end

  def get_non_user
    @non_user
  end

  def validates_has_user
    if get_user.nil?
      errors.add(:user, 'La colaboración debe tener un usuario asociado.')
    end
  end

  def self.bank_filename(date, full_path = true)
    filename = "podemos.orders.#{date.year}.#{date.month}"
    if full_path
      "#{Rails.root}/db/podemos/#{filename}.csv"
    else
      filename
    end
  end

  BANK_FILE_LOCK = "#{Rails.root}/db/podemos/podemos.orders.#{Rails.env}.lock"
  def self.bank_file_lock(status)
    if status
      folder = File.dirname BANK_FILE_LOCK
      FileUtils.mkdir_p(folder) unless File.directory?(folder)
      FileUtils.touch BANK_FILE_LOCK
    else
      File.delete(BANK_FILE_LOCK) if File.exists? BANK_FILE_LOCK
    end
  end

  def self.has_bank_file?(date)
    [File.exist?(BANK_FILE_LOCK), File.exist?(bank_filename(date))]
  end

  def self.update_paid_unconfirmed_bank_collaborations(orders)
    Collaboration.unconfirmed.joins(:order).merge(orders).update_all(status: 3)
  end

  private

  def check_frequency
    self.frequency = nil
  end
end
