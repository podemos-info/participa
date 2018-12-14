require 'fileutils'
class Collaboration < ActiveRecord::Base
  include Rails.application.routes.url_helpers

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
  validates :payment_type, :amount, :frequency, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true
  validates :user_id, uniqueness: { scope: :deleted_at }, allow_nil: true, allow_blank: true, unless: :skip_queries_validations
  validates :non_user_email, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true, unless: :skip_queries_validations
  validates :non_user_document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true, unless: :skip_queries_validations
  validates :non_user_email, :non_user_document_vatid, :non_user_data, presence: true, if: Proc.new { |c| c.user.nil? }
    
  validate :validates_not_passport
  validate :validates_age_over
  validate :validates_has_user

  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, numericality: true, if: :has_ccc_account?
  validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, presence: true, if: :has_ccc_account?
  validate :validates_ccc, if: :has_ccc_account?

  validates :iban_account, presence: true, if: :has_iban_account?
  validate :validates_iban, if: :has_iban_account?

  AMOUNTS = {"5 €" => 500, "10 €" => 1000, "20 €" => 2000, "30 €" => 3000, "50 €" => 5000, "100 €" => 10000, "200 €" => 20000, "500 €" => 50000}
  FREQUENCIES = {"Mensual" => 1, "Trimestral" => 3, "Anual" => 12}
  STATUS = {"Sin pago" => 0, "Error" => 1, "Sin confirmar" => 2, "OK" => 3, "Alerta" => 4,"Migración" =>9}

  scope :created, -> { all }
  scope :live, -> { where(deleted_at: nil)  }
  scope :credit_cards, -> { live.where(payment_type: 1)}
  scope :banks, -> { live.where.not(payment_type: 1)}
  scope :bank_nationals, -> { live.where.not(payment_type: 1).where.not("collaborations.payment_type = 3 and iban_account NOT LIKE ?", "ES%") }
  scope :bank_internationals, -> { live.where(payment_type: 3).where("iban_account NOT LIKE ?", "ES%") }
  scope :frequency_month, -> { live.where(frequency: 1)}
  scope :frequency_quarterly, -> { live.where(frequency: 3)}
  scope :frequency_anual, -> { live.where(frequency: 12) }
  scope :amount_1, -> { live.where("amount < 1000")}
  scope :amount_2, -> { live.where("amount >= 1000 and amount < 2000")}
  scope :amount_3, -> { live.where("amount > 2000")}

  scope :incomplete, -> { live.where(status: 0)}
  scope :unconfirmed, -> { live.where(status: 2)}
  scope :active, -> { live.where(status: 3)}
  scope :warnings, -> { live.where(status: 4)}
  scope :errors, -> { live.where(status: 1)}
  scope :suspects, -> { banks.active.where("(select count(*) from orders o where o.parent_id=collaborations.id and o.payable_at>? and o.status=5)>2",Date.today-8.months) }
  scope :legacy, -> { live.where.not(non_user_data: nil)}
  scope :non_user, -> { live.where(user_id: nil)}
  scope :deleted, -> { only_deleted }

  scope :full_view, -> { with_deleted.eager_load(:order) }

  scope :autonomy_cc, -> { live.where(for_autonomy_cc: true)}
  scope :town_cc, -> { live.where(for_town_cc: true)}
  scope :island_cc, -> { live.where(for_island_cc: true)}

  after_create :set_initial_status
  before_save :check_spanish_bic
  before_save do
    self.iban_account.upcase! if self.iban_account.present?
  end

  def territorial_assignment= value
    self.for_town_cc = self.for_island_cc = self.for_autonomy_cc = false
    case value.to_sym
    when :town then self.for_town_cc = true
    when :island then self.for_island_cc = true
    when :autonomy then self.for_autonomy_cc = true
    end
  end

  def territorial_assignment
    if self.for_town_cc
      :town
    elsif self.for_island_cc
      :island
    elsif self.for_autonomy_cc
      :autonomy
    else
      :country
    end     
  end

  def set_initial_status
    self.status = 0
  end

  def has_payment?
    self.status>0
  end
  
  def check_spanish_bic
    self.set_warning! "Marcada como alerta porque el número de cuenta indica un código de entidad inválido o no encontrado en la base de datos de BICs españoles." if [2,3].include? self.status and self.is_bank_national? and calculate_bic.nil?
  end

  def validates_not_passport
    if self.user and self.user.is_passport? 
      self.errors.add(:user, "No puedes colaborar si no dispones de DNI o NIE.")
    end
  end

  def validates_age_over
    if self.user and self.user.born_at and self.user.born_at > Date.today-18.years
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
    iban_validation = IBANTools::IBAN.valid?(self.iban_account)
    ccc_validation = self.iban_account&.start_with?("ES") ? BankCccValidator.validate(self.iban_account[4..-1]) : true
    unless iban_validation and ccc_validation
      self.errors.add(:iban_account, "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
    end
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
    self.has_iban_account? and !self.iban_account.start_with?("ES")
  end

  def has_ccc_account?
    self.payment_type==2
  end

  def has_iban_account?
    self.payment_type==3
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
    "#{"%04d" % ccc_entity}#{"%04d" % ccc_office}#{"%02d" % ccc_dc}#{"%010d" % ccc_account}" if ccc_account
  end

  def pretty_ccc_full 
    "#{"%04d" % ccc_entity} #{"%04d" % ccc_office} #{"%02d" % ccc_dc} #{"%010d" % ccc_account}" if ccc_account
  end

  def calculate_iban
    iban = nil
    if iban_account.empty? && ccc_account.present?
      ccc = self.ccc_full
      iban = 98-("#{ccc}142800".to_i % 97)
      iban = "ES#{iban.to_s.rjust(2,"0")}#{ccc}"
    end
    iban = iban_account.gsub(" ","") if iban.nil? && iban_account.present?
    iban
  end
  def calculate_bic
    bic = Podemos::SpanishBIC[ccc_entity] if ccc_account and (not iban_account or is_bank_national?)
    bic = Podemos::SpanishBIC[iban_account[4..7].to_i] if not bic and iban_account and !iban_account.empty? and iban_account[0..1]=="ES"
    bic = iban_bic.gsub(" ","") if not bic and iban_bic and !iban_bic.empty?
    bic
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def is_recurrent?
    true
  end

  def is_payable?
    [2,3].include? self.status and self.deleted_at.nil? and self.valid? and (not self.user or self.user.deleted_at.nil?)
  end

  def is_active?
    self.status > 1 and self.deleted_at.nil?
  end

  def has_confirmed_payment?
    self.status > 2 and self.deleted_at.nil?
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def first_order
    self.order.sort {|a,b| a.payable_at <=> b.payable_at }.detect {|o| o.is_payable? or o.is_paid? }
  end

  def last_order_for date
    self.order.sort {|a,b| b.payable_at <=> a.payable_at }.detect {|o| o.payable_at.unique_month <= date.unique_month and (o.is_payable? or o.is_paid?) }
  end

  def create_order date, maybe_first=false
    is_first = false
    if maybe_first and not self.has_confirmed_payment?
      if self.first_order.nil?
        is_first = true
      elsif self.first_order.payable_at.unique_month==date.unique_month
        return self.first_order
      end
    end

    date = date.change(day: Order.payment_day) if not (is_first and self.is_credit_card?)
    order = Order.new do |o|
      o.user = self.user
      o.parent = self
      o.reference = "Colaboración " + I18n.localize(date, :format => "%B %Y")
      o.first = is_first
      o.amount = self.amount*self.frequency
      o.payable_at = date
      o.payment_type = self.is_credit_card? ? 1 : 3
      o.payment_identifier = self.payment_identifier
      if self.user && !self.user.vote_autonomy_code.empty?
        o.autonomy_code = self.get_vote_autonomy_code if self.for_autonomy_cc
        o.town_code = self.get_vote_town if self.for_town_cc
        o.island_code = self.get_vote_island_code if self.for_island_cc
      end
    end
    order
  end

  def payment_identifier
    if self.is_credit_card?
      self.redsys_identifier
    elsif self.has_ccc_account?
      "#{calculate_iban}/#{calculate_bic}"
    else
      "#{self.iban_account}/#{self.iban_bic}"
    end
  end

  def payment_processed! order
    if order.is_paid?
      if order.has_warnings?
        self.set_warning! "Marcada como alerta porque se han producido alertas al procesar el pago."
      else
        self.set_ok!
      end

      if self.is_credit_card? and order.first
        self.update_attributes redsys_identifier: order.payment_identifier, redsys_expiration: order.redsys_expiration
      end
    elsif self.has_payment?
      self.set_error! "Marcada como error porque se ha producido un error al procesar el pago."
    end
  end

  MAX_RETURNED_ORDERS = 2
  def returned_order! error=nil, warn=false
    # FIXME: this should be orders for the inflextions
    # http://guides.rubyonrails.org/association_basics.html#the-has-many-association
    # should have a solid test base before doing this change and review where .order
    # is called. 

    if self.is_payable?
      if error
        self.set_error! "Marcada como error porque se ha devuelto una orden con código asociado a error en la colaboración."
      elsif warn
        self.set_warning! "Marcada como alerta porque se ha devuelto una orden con código asociado a alerta en la colaboración."
      elsif self.order.count >= MAX_RETURNED_ORDERS
        last_order = self.last_order_for(Date.today)
        if last_order
          last_month = last_order.payable_at.unique_month 
        else
          last_month = self.created_at.unique_month
        end
        self.set_error! "Marcada como error porque se ha superado el límite de órdenes devueltas consecutivas." if Date.today.unique_month - 1 - last_month >= self.frequency*MAX_RETURNED_ORDERS
      end
      # added in diferent block code to maintain code coherence and to allow future code refactor

      # send diferent mail in diferent
      #if !self.send_email_at and self.user
      #  if self.payment_type == 1 # paid with CreditCard
      #    if warn
      #      collaborations_mailer.creditcard_expired_email(self.user).deliver
      #    elsif error
      #      collaborations_mailer.creditcard_error_email(self.user).deliver
      #    end
      #  else
      #    if self.order.count == 1
      #      collaborations_mailer.receipt_returned_email(self.user).deliver
      #    else
      #      collaborations_mailer.receipt_suspended_email(self.user).deliver
      #    end
      #  end
      #end
    end
  end

  def has_warnings?
    self.status==4
  end

  def has_errors?
    self.status==1
  end

  def set_error! reason
    self.update_attribute :status, 1
    self.add_comment reason
  end

  def set_active!
    self.update_attribute(:status, 2) if self.status < 2
  end

  def set_ok!
    self.update_attribute :status, 3
  end

  def set_warning! reason
    self.update_attribute :status, 4
    self.add_comment reason
  end

  def must_have_order? date
    this_month = Date.today.unique_month

    # first order not created yet, must have order this month, or next if its paid by bank and was created this month after payment day
    if self.first_order.nil?
      next_order = this_month
      next_order += 1 if self.is_bank? and self.created_at.unique_month==next_order and self.created_at.day >= Order.payment_day

    # first order created on asked date
    elsif self.first_order.payable_at.unique_month == date.unique_month
      return true

    # mustn't have order on months before it first order
    elsif self.first_order.payable_at.unique_month > date.unique_month
      return false

    # calculate next order month based on last paid order
    else
      next_order = self.last_order_for(date-1.month).payable_at.unique_month + self.frequency
      next_order = Date.today.unique_month if next_order<Date.today.unique_month  # update next order when a payment was missed
    end

    (date.unique_month >= next_order) and (date.unique_month-next_order) % self.frequency == 0
  end

  def get_orders date_start=Date.today, date_end=Date.today, create_orders = true
    saved_orders = Hash.new {|h,k| h[k] = [] }

    self.order.select {|o| o.payable_at > date_start.beginning_of_month and o.payable_at < date_end.end_of_month} .each do |o|
      saved_orders[o.payable_at.unique_month] << o
    end

    current = date_start

    orders = []

    while current<=date_end
      # month orders sorted by creation date
      month_orders = saved_orders[current.unique_month].sort_by { |o| o.created_at }

      # valid orders without errors
      valid_orders = month_orders.select {|o| not o.has_errors? }
      
      # if collaboration is active, should create orders, this month should have an order and it doesn't have a valid saved order, create it (not persistent)
      if self.deleted_at.nil? and create_orders and self.must_have_order? current and valid_orders.empty?
        order = self.create_order current, orders.empty?
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

  def fix_status!
    if not self.valid? and not self.has_errors?
      self.set_error! "Marcada como error porque la colaboración no supera todas las validaciones antes de generar su orden."
      true
    else
      false
    end
  end

  def charge!
    if self.is_payable?
      order = self.get_orders[0] # get orders for current month
      order = order[-1] if order # get last order for current month
      if order and order.is_chargeable?
        if self.is_credit_card?
          order.redsys_send_request if self.is_active?
        else
          order.save
        end
      end
    end
  end

  def get_bank_data date
    order = self.last_order_for date
    if order and order.payable_at.unique_month == date.unique_month and order.is_chargeable?
      col_user = self.get_user
      [ "%02d%02d%06d" % [ date.year%100, date.month, order.id%1000000 ], 
          col_user.full_name.mb_chars.upcase.to_s, col_user.document_vatid.upcase, col_user.email, 
          col_user.address.mb_chars.upcase.to_s, col_user.town_name.mb_chars.upcase.to_s, 
          col_user.postal_code, col_user.country.upcase, 
          self.calculate_iban, self.ccc_full, self.calculate_bic, 
          order.amount/100, order.due_code, order.url_source, self.id, 
          self.created_at.strftime("%d-%m-%Y"), order.reference, order.payable_at.strftime("%d-%m-%Y"), 
          self.frequency_name, col_user.full_name.mb_chars.upcase.to_s ]
    end
  end

  after_initialize :parse_non_user
  before_save :format_non_user

  class NonUser
    def initialize(args)
      [:legacy_id, :full_name, :document_vatid, :email, :address, :town_name, :postal_code, :country, :province, :phone, :province_name, :island_name, :autonomy_name, :ine_town].each do |var|
        instance_variable_set("@#{var}", args[var]) if args.member? var
      end
    end

    attr_accessor :legacy_id, :full_name, :document_vatid, :email, :address, :town_name, :postal_code, :country, :province, :phone, :province_name, :island_name, :autonomy_name, :ine_town

    def to_s
      "#{full_name} (#{document_vatid} - #{email})"
    end
  end

  def parse_non_user
    @non_user = if self.non_user_data then YAML.load(self.non_user_data) else nil end
  end

  def format_non_user
    if @non_user then
      self.non_user_data = YAML.dump(@non_user)
      self.non_user_document_vatid = @non_user.document_vatid
      self.non_user_email = @non_user.email
    else
      self.non_user_data = self.non_user_document_vatid = self.non_user_email = nil
    end
  end

  def set_non_user info
    @non_user = if info.nil? then nil else NonUser.new(info) end
    format_non_user
  end

  def get_user
    if self.user
      self.user
    else
      @non_user
    end
  end

  def get_vote_town
    if self.user
      self.user.vote_town
    else
      self.get_non_user.ine_town
    end
  end

  def get_vote_autonomy_code
    if self.user
      self.user.vote_autonomy_code
    else
      vote_province_code = "p_" % + self.get_non_user.ine_town.slice(2,2)
      Podemos::GeoExtra::AUTONOMIES[vote_province_code][0]
    end
  end

  def get_vote_island_code
    if self.user
      self.user.vote_island_code
    else
      Podemos::GeoExtra::ISLANDS[self.get_non_user.ine_town][0]
    end
  end
  def get_non_user
    @non_user
  end

  def vote_town
    :ine_town
  end

  def town_name
    :town_name
  end

  def province_name
    :province_name
  end

  def autonomy_name
    :autonomy_name
  end

  def island_name
    :island_name
  end

  def validates_has_user
    if self.get_user.nil?
      self.errors.add(:user, "La colaboración debe tener un usuario asociado.")
    end
  end

  def self.bank_filename date, full_path=true
    filename = "podemos.orders.#{date.year.to_s}.#{date.month.to_s}"
    if full_path
      "#{Rails.root}/db/podemos/#{filename}.csv"
    else
      filename
    end      
  end

  BANK_FILE_LOCK = "#{Rails.root}/db/podemos/podemos.orders.#{Rails.env}.lock"
  def self.bank_file_lock status
    if status 
      folder = File.dirname BANK_FILE_LOCK
      FileUtils.mkdir_p(folder) unless File.directory?(folder)
      FileUtils.touch BANK_FILE_LOCK
    else
      File.delete(BANK_FILE_LOCK) if File.exists? BANK_FILE_LOCK
    end    
  end

  def self.has_bank_file? date
    [ File.exists?(BANK_FILE_LOCK), File.exists?(self.bank_filename(date)) ]
  end

  def self.update_paid_unconfirmed_bank_collaborations orders
    Collaboration.unconfirmed.joins(:order).merge(orders).update_all(status: 3)
  end
end
