class MicrocreditLoan < ActiveRecord::Base
  apply_simple_captcha
  acts_as_paranoid

  belongs_to :microcredit
  belongs_to :user, -> { with_deleted }
  belongs_to :microcredit_option

  belongs_to :transferred_to, inverse_of: :original_loans, class_name: "MicrocreditLoan"
  has_many :original_loans, inverse_of: :transferred_to, class_name: "MicrocreditLoan", foreign_key: :transferred_to_id

  attr_accessor :first_name, :last_name, :email, :address, :postal_code, :town, :province, :country

  validates :document_vatid, valid_spanish_id: true, if: :has_not_user?
  validates :first_name, :last_name, :email, :address, :postal_code, :town, :province, :country, presence: true, if: :has_not_user?

  validates :email, email: true, if: :has_not_user?

  validates :amount, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true

  validate :amount, :check_amount, on: :create
  validate :user, :check_user_limits, on: :create
  validate :microcredit, :check_microcredit_active, on: :create
  validate :validates_not_passport
  validate :validates_age_over

  validate :microcredit_option_without_children

  validates :iban_account, presence: true, on: :create
  validates :iban_bic, presence: true, on: :create, if: :is_bank_international?
  validate :validates_iban , if: :iban_account
  validate :validates_bic, if: :iban_bic

  scope :not_counted, -> { where(counted_at:nil) }
  scope :counted, -> { where.not(counted_at:nil) }
  scope :not_confirmed, -> { where(confirmed_at:nil) }
  scope :confirmed, -> { where.not(confirmed_at:nil) }
  scope :not_discarded, -> { where(discarded_at:nil) }
  scope :discarded, -> { where.not(discarded_at:nil) }
  scope :not_returned, -> { confirmed.where(returned_at:nil) }
  scope :returned, -> { where.not(returned_at:nil) }
  scope :transferred, -> { where.not(transferred_to_id:nil)}
  scope :renewal, -> { joins(:original_loans).distinct(:microcredit_id)}

  scope :renewables, -> { confirmed.joins(:microcredit).merge(Microcredit.renewables).distinct }
  scope :not_renewed, -> { renewables.not_returned }

  scope :recently_renewed, -> { confirmed.where.not(transferred_to:nil).where("returned_at>?",30.days.ago) }
  scope :ignore_discarded, -> { where("discarded_at is null or counted_at is not null") }

  scope :phase, -> { joins(:microcredit).where("microcredits.reset_at is null or (microcredit_loans.counted_at IS NULL and microcredit_loans.created_at>microcredits.reset_at) or microcredit_loans.counted_at>microcredits.reset_at") }
  scope :upcoming_finished, -> { joins(:microcredit).merge(Microcredit.upcoming_finished) }

  after_initialize do |microcredit|
    if user
      set_user_data user
      self.document_vatid = user.document_vatid
    elsif user_data
      set_user_data YAML.load(self.user_data)
    else
      self.country = "ES"
    end
  end

  before_save do
    self.iban_account.upcase! if self.iban_account.present?
  end

  def set_user_data _user
    self.first_name = _user[:first_name]
    self.last_name = _user[:last_name]
    self.email = _user[:email]
    self.address = _user[:address]
    self.postal_code = _user[:postal_code]
    self.town = _user[:town]
    self.province = _user[:province]
    self.country = _user[:country]
  end

  def country_name
    _country = Carmen::Country.coded(self.country)
    if _country
      _country.name
    else
      self.country
    end
  end

  def province_name
    _country = Carmen::Country.coded(self.country)
    _prov = _country.subregions.coded(self.province) if _country and self.province and not _country.subregions.empty?
    if _prov
      _prov.name
    else
      self.province
    end
  end

  def town_name
    _country = Carmen::Country.coded(self.country)
    _prov = _country.subregions.coded(self.province) if _country and self.province and not _country.subregions.empty?
    _town = _prov.subregions.coded(self.town) if _prov and not _prov.subregions.empty?
    if _town
      _town.name
    else
      self.town
    end
  end

  before_save do
    if user
      self.user_data = nil
    else
      self.user_data = {first_name: first_name, last_name: last_name, email: email, address: address, postal_code: postal_code, town: town, province: province, country: country}.to_yaml
    end
    if self.document_vatid
      self.document_vatid.upcase!
      self.document_vatid.strip!
    end
  end

  def update_counted_at
    must_count = false
    replacement = nil
    if self.counted_at.nil? and self.discarded_at.nil?
      replacement = self.microcredit.loans.where(amount: self.amount).counted.discarded.order(created_at: :asc).first
      if not replacement and not self.confirmed_at.nil?
        replacement = self.microcredit.loans.where(amount: self.amount).counted.not_confirmed.order(created_at: :asc).first
      end
      if replacement
        must_count = true
      else
        must_count = self.microcredit.should_count?(amount, !self.confirmed_at.nil?)
      end
    end

    if must_count
      if replacement
        self.counted_at = replacement.counted_at
        replacement.counted_at = nil
        MicrocreditLoan.transaction do
          self.save if replacement.save
        end
      else
        self.counted_at = DateTime.now
        self.save
      end
      self.microcredit.clear_cache
    end
  end

  def has_not_user?
    user.nil?
  end

  def validates_not_passport
    if self.user and self.user.is_passport? 
      self.errors.add(:user, "No puedes suscribir un microcrédito si no dispones de DNI o NIE.")
    end
  end

  def validates_age_over
    if self.user and self.user.born_at > Date.today-18.years
      self.errors.add(:user, "No puedes suscribir un microcrédito si eres menor de edad.")
    end
  end

  def microcredit_option_without_children
    if self.microcredit.microcredit_options.any?
      errors.add(:microcredit_option_id, "Debes elegir algún elemento") if microcredit_option.blank? || microcredit_option.children.any?
    end
  end

  def is_bank_international?
    self.iban_account && !self.iban_account.start_with?("ES")
  end

  def validates_iban
    iban_validation = IBANTools::IBAN.valid?(self.iban_account)
    ccc_validation = self.iban_account&.start_with?("ES") ? BankCccValidator.validate(self.iban_account[4..-1]) : true
    unless iban_validation and ccc_validation
      self.errors.add(:iban_account, "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
    end
  end

  def calculate_bic
    bic = Podemos::SpanishBIC[iban_account[4..7].to_i] if iban_account and !iban_account.empty? and iban_account[0..1]=="ES"
    bic = iban_bic.gsub(" ","") if not bic and iban_bic and !iban_bic.empty?
    bic
  end

  def validates_bic
    self.iban_bic =  calculate_bic if self.iban_account && self.iban_account.start_with?("ES")
    true
  end

  def check_amount
    if self.confirmed_at.nil? && self.amount && !self.microcredit.has_amount_available?(amount)
      self.errors.add(:amount, "Lamentablemente, ya no quedan préstamos por esa cantidad.")
    end
  end

  def check_user_limits
    limit = self.microcredit.loans.where(ip:self.ip).count>Rails.application.secrets.microcredit_loans["max_loans_per_ip"]
    if not limit
      loans = self.microcredit.loans.where(document_vatid:self.document_vatid).pluck(:amount)
      limit = ((loans.length>=Rails.application.secrets.microcredit_loans["max_loans_per_user"]) or (loans.sum + self.amount>Rails.application.secrets.microcredit_loans["max_loans_sum_amount"])) if not limit and self.amount
    end

    self.errors.add(:user, "Lamentablemente, no es posible suscribir este microcrédito.") if limit
  end

  def check_microcredit_active
    if self.confirmed_at.nil? && !self.microcredit.is_active?
      self.errors.add(:microcredit, "La campaña de microcréditos no está activa en este momento.")
    end
  end

  def self.count_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.count
  end

  def self.count_confirmed_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.confirmed.count
  end

  def self.count_counted_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.counted.count
  end

  def self.count_discarded_current
    MicrocreditLoan.upcoming_finished.discarded.count
  end

  def self.amount_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.sum(:amount)
  end

  def self.amount_confirmed_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.confirmed.sum(:amount)
  end

  def self.amount_counted_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.counted.sum(:amount)
  end

  def self.amount_discarded_current
    MicrocreditLoan.upcoming_finished.discarded.sum(:amount)
  end

  def self.amount_discarded_counted_current
    MicrocreditLoan.upcoming_finished.discarded.counted.sum(:amount)
  end

  def self.unique_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.distinct(:document_vatid).count(:document_vatid)
  end

  def self.unique_confirmed_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.confirmed.distinct(:document_vatid).count(:document_vatid)
  end

  def self.unique_counted_current
    MicrocreditLoan.upcoming_finished.ignore_discarded.counted.distinct(:document_vatid).count(:document_vatid)
  end

  def possible_user
    @possible_user ||= self.user.nil? && User.find_by_document_vatid(self.document_vatid)
  end

  def unique_hash
     Digest::SHA1.hexdigest "#{id}-#{created_at}-#{document_vatid.upcase}"
  end

  def renew! new_campaign
    new_loan = self.dup
    new_loan.microcredit = new_campaign
    new_loan.counted_at = DateTime.now
    new_loan.save!
    self.transferred_to = new_loan
    self.returned_at = DateTime.now
    save!
  end

  def renewable?
    !self.confirmed_at.nil? && self.returned_at.nil? && self.microcredit.renewable?
  end

  def return!
    return false if self.confirmed_at.nil? || !self.returned_at.nil?
    self.returned_at = DateTime.now
    save!
    return true
  end

  def confirm!
    return false if !self.confirmed_at.nil?
    self.discarded_at = nil
    self.confirmed_at = DateTime.now
    self.save!
    self.update_counted_at
    return true
  end

  def unconfirm!
    return false if self.confirmed_at.nil?
    self.confirmed_at = nil
    save!
    return true
  end

  def discard!
    return false if !self.discarded_at.nil?
    self.discarded_at = DateTime.now
    self.confirmed_at = nil
    self.save!
    return true
  end
end
