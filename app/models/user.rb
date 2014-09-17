class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, :document_type, :document_vatid, :born_at, presence: true
  validates :address, :postal_code, :town, :province, :country, presence: true
  validates :email, :document_vatid, uniqueness: true
  validates :terms_of_service, acceptance: true
#  validates :phone, numericality: true

  #validates :document_type, inclusion: { in: %w(1 2 3), message: "tipo de documento no válido" }
  validates :born_at, inclusion: { in: Date.civil(1920, 1, 1)..Date.civil(2015, 1, 1),
                                   message: "debes haber nacido después de 1920" }

  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?

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

end
