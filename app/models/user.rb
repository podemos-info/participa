class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, :document_type, :document_vatid, :born_at, presence: true
  validates :address, :postal_code, :town, :province, :country, presence: true
  validates :email, :document_vatid, uniqueness: true
  validates :terms_of_service, acceptance: true

  #validates :document_type, inclusion: { in: %w(1 2),
  #                              message: "tipo de documento no válido" }
  validates :born_at, inclusion: { in: Date.civil(1920, 1, 1)..Date.civil(2015, 1, 1),
                                   message: "debes haber nacido antes de 1920" }

  DOCUMENTS_TYPE = [["DNI/NIE", 1], ["Pasaporte", 2]]

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def is_admin?
    admin == 1
  end

end
