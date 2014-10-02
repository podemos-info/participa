class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :address, :postal_code, :town, :province, :country, presence: true
  validates :email, :document_vatid, uniqueness: true
  validates :terms_of_service, acceptance: true
  validates :country, length: {minimum: 1, maximum: 2}
  #validates :phone, numericality: true, allow_blank: true
  # TODO: phone - cambiamos el + por el 00 al guardar 
  validates :document_type, inclusion: { in: [1, 2, 3], message: "tipo de documento no válido" }
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, inclusion: { in: Date.civil(1920, 1, 1)..Date.civil(2015, 1, 1),
                                   message: "debes haber nacido después de 1920" }, allow_blank: true
  # TODO: al crear setear has_legacy_password = true
  # TODO: validacion if country == ES then postal_code /(\d5)/
  attr_accessor :sms_user_token_given

  has_many :votes 

  scope :wants_newsletter, -> {where(wants_newsletter: true)}

  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  def get_or_create_vote election_id
    Vote.where(user_id: self.id, election_id: election_id).first_or_create
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Email-only-sign-up
  def password_required?
    super if confirmed?
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Email-only-sign-up
  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def generate_reset_password_token
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    self.update_attribute(:reset_password_token, hashed_token)
    self.update_attribute(:reset_password_sent_at, Time.now.utc)
    return raw_token
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
    SecureRandom.hex(3).upcase
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
