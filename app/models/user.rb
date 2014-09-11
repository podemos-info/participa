class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, :document_type, :document_vatid, :born_at, presence: true
  validates :email, :document_vatid, uniqueness: true
  validates :terms_of_service, acceptance: true

  DOCUMENTS_TYPE = [["DNI/NIE", 1], ["Pasaporte", 2]]

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def is_admin?
    admin == 1
  end

end
