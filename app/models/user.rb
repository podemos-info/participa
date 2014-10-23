class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  acts_as_paranoid

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :address, :postal_code, :town, :province, :country, presence: true
  validates :email, :document_vatid, uniqueness: { case_sensitive: false }
  validates :terms_of_service, acceptance: true
  validates :over_18, acceptance: true
  #validates :country, length: {minimum: 1, maximum: 2}
  #validates :phone, numericality: true, allow_blank: true
  validates :phone, uniqueness: true, allow_blank: true, allow_nil: true
  # TODO: phone - cambiamos el + por el 00 al guardar 
  validates :document_type, inclusion: { in: [1, 2, 3], message: "tipo de documento no válido" }
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, date: true, allow_blank: true # gem date_validator
  validates :born_at, inclusion: { in: Date.civil(1900, 1, 1)..Date.civil(1998, 1, 1),
                                   message: "debes haber nacido después de 1900" }, allow_blank: true
  # TODO: validacion if country == ES then postal_code /(\d5)/
  attr_accessor :sms_user_token_given
  attr_accessor :login

  has_many :votes 
  has_one :collaboration

  scope :wants_newsletter, -> {where(wants_newsletter: true)}

  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(document_vatid) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def get_or_create_vote election_id
    Vote.where(user_id: self.id, election_id: election_id).first_or_create
  end

  def is_document_dni?
    self.document_type == 1
  end

  def is_document_nie?
    self.document_type == 2
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def is_admin?
    self.admin
  end

  def is_valid_user?
    self.phone? and self.sms_confirmed_at?
  end

  def is_valid_phone?
    self.sms_confirmed_at?
  end

  def generate_sms_token
    SecureRandom.hex(4).upcase
  end

  def set_sms_token!
    self.update_attribute(:sms_confirmation_token, generate_sms_token)
  end

  def send_sms_token!
    require 'sms'
    self.update_attribute(:confirmation_sms_sent_at, DateTime.now)
    SMS::Sender.send_message(self.phone, self.sms_confirmation_token)
  end

  def check_sms_token(token)
    if token == self.sms_confirmation_token
      self.update_attribute(:sms_confirmed_at, DateTime.now)
      true
    else 
      false
    end
  end

  def document_type_name
    User::DOCUMENTS_TYPE.select{|v| v[1] == self.document_type }[0][0]
  end

  def country_name
    if self.country.length > 3 
      self.country
    else
      Carmen::Country.coded(self.country).name
    end
  end

  def province_name
    if self.province.length > 3 
      self.province
    else
      Carmen::Country.coded(self.country).subregions.coded(self.province).name
    end
  end

end
