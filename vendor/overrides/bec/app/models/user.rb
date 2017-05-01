
require_dependency Rails.root.join('app', 'models', 'user').to_s

class User
	
	belongs_to :verified_by, class_name: "User", foreign_key: "verified_by_id" #, counter_cache: :verified_by_id

  validates :district, presence: true
  validates :inscription, acceptance: true

  DISTRICT = [["Ciutat Vella", 1], ["Eixample", 2], ["Sants-Montjuïc", 3], ["Les Corts", 4], ["Sarrià-Sant Gervasi", 5], ["Gràcia", 6], ["Horta-Guinardó", 7], ["Nou Barris", 8], ["Sant Andreu", 9], ["Sant Martí", 0]]

  def district_name
    User::DISTRICT.select{|v| v[1] == self.district }[0][0]
  end

  validates :born_at, inclusion: { in: Date.civil(1900, 1, 1)..Date.today-16.years,
    message: "debes ser mayor de 16 años" }, allow_blank: true

  before_validation :set_location

  def set_location
    self.country = "ES" if self.country.nil?
    self.province = "B" if self.province.nil?
    self.town = "m_08_019_3" if self.town.nil?
  end

  def is_verified?
    if Rails.application.secrets.features["verification_presencial"]
      self.verified_by_id? or self.sms_confirmed_at?
    else
      self.verified?
    end
  end

  def vote_district_numeric
    "%02d" % + self.district
  end

  def vote_district_name
    self.district_name
  end

  def vote_district_code
    "d_%02d" % + self.district
  end
  
  def verify! user
    self.verified_at = DateTime.now
    self.verified_by = user
    self.save
    VerificationMailer.verified(self).deliver
  end

  def list_groups
    self.groups.pluck(:name).map{|group| group.downcase.parameterize('-')}
  end

end
