class MicrocreditLoan < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :microcredit
  belongs_to :user

  attr_accessor :skip_callbacks
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

  scope :counted, -> { where.not(counted_at:nil) }
  scope :confirmed, -> { where.not(confirmed_at:nil) }
  scope :phase, -> { joins(:microcredit).where("microcredits.reset_at is null or microcredit_loans.created_at>microcredits.reset_at or microcredit_loans.counted_at>microcredits.reset_at") }
  
  after_save :update_counted_at, unless: :skip_callbacks

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

  before_save do
    if user
      self.user_data = nil
    else
      self.user_data = {first_name: first_name, last_name: last_name, email: email, address: address, postal_code: postal_code, town: town, province: province, country: country}.to_yaml
    end
  end

  def update_counted_at
    if self.counted_at.nil? and self.microcredit.should_count?(amount, !confirmed_at.nil?)
      unconfirmed = confirmed_at.nil? ? nil : self.microcredit.loans.where(amount: amount).where(confirmed_at:nil).where.not(counted_at:nil).first

      if unconfirmed

        self.counted_at = unconfirmed.counted_at
        unconfirmed.counted_at = nil
          
        unconfirmed.skip_callbacks = self.skip_callbacks = true
        MicrocreditLoan.transaction do
          self.save if unconfirmed.save
        end
        unconfirmed.skip_callbacks = self.skip_callbacks = false
      else
        self.counted_at = DateTime.now
        self.save
      end
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

  def check_amount
    if self.amount and not self.microcredit.has_amount_available? amount
      self.errors.add(:amount, "Lamentablemente, ya no quedan préstamos por esa cantidad.")
    end
  end

  def check_user_limits
    limit = self.microcredit.loans.where(ip:self.ip).count>50
    if not limit
      if self.user
        loans = self.microcredit.loans.where(user:self.user).pluck(:amount)
      else
        limit = User.where("lower(document_vatid) = ?", self.document_vatid).count>0
        loans = self.microcredit.loans.where(document_vatid:self.document_vatid).pluck(:amount) if not limit
      end
      limit = loans.length>10 or loans.sum>10000 if not limit
    end

    self.errors.add(:user, "Lamentablemente, no es posible suscribir este microcrédito.") if limit
  end

  def check_microcredit_active
    if not self.microcredit.is_active?
      self.errors.add(:microcredit, "La campaña de microcréditos no está activa en este momento.")
    end
  end
end
