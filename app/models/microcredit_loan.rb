class MicrocreditLoan < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :microcredit
  belongs_to :user

  attr_accessor :first_name, :last_name, :email, :document_vatid, :address, :postal_code, :town, :province, :country

  # TODO: valid_nie: true also
  validates :document_vatid, valid_nif: true, if: :has_not_user?
  validates :first_name, :last_name, :email, :address, :postal_code, :town, :province, :country, presence: true, if: :has_not_user?

  # FIXME: review email_validator without email
  #  m = MicrocreditLoan.new
  #  m.valid? 
  #  NoMethodError: undefined method `length' for nil:NilClass
  #   from app/validators/email_validator.rb:6:in `validate_each'
  validates :email, email: true, if: :has_not_user?

  validates :amount, presence: true
  validates :terms_of_service, acceptance: true
  validates :minimal_year_old, acceptance: true

  scope :confirmed, -> { where.not(confirmed_at:nil) }
  scope :current, -> { joins(:microcredit).where("microcredits.reset_at is null or microcredit_loans.created_at>microcredits.reset_at") }

  after_initialize do |microcredit|
    if user
      set_user_data user
    elsif user_data
      set_user_data YAML.load(self.user_data)
    else
      self.country = "ES"
    end
  end

  def set_user_data _user
    self.first_name = _user["first_name"]
    self.last_name = _user["last_name"]
    self.email = _user["email"]
    self.address = _user["address"]
    self.postal_code = _user["postal_code"]
    self.town = _user["town"]
    self.province = _user["province"]
    self.country = _user["country"]
  end

  before_save do |microcredit|
    if user
      self.user_data = nil
    else
      self.user_data = {first_name: first_name, last_name: last_name, email: email, address: address, postal_code: postal_code, town: town, province: province, country: country}.to_yaml
    end
  end

  def has_not_user?
    user.nil?
  end
end
