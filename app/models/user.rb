class User < ActiveRecord::Base

  include Rails.application.routes.url_helpers
  require 'phone'

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  before_save :control_vote_town

  acts_as_paranoid
  has_paper_trail

  has_many :votes, dependent: :destroy
  has_one :collaboration, dependent: :destroy

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :address, :postal_code, :town, :province, :country, :born_at, presence: true
  validates :email, confirmation: true, on: :create, :email => true
  validates :email_confirmation, presence: true, on: :create
  validates :terms_of_service, acceptance: true
  validates :over_18, acceptance: true
  validates :document_type, inclusion: { in: [1, 2, 3], message: "Tipo de documento no válido" }
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, date: true, allow_blank: true # gem date_validator
  validates :born_at, inclusion: { in: Date.civil(1900, 1, 1)..Date.today-18.years,
    message: "debes ser mayor de 18 años" }, allow_blank: true
  validates :phone, numericality: true, allow_blank: true
  validates :unconfirmed_phone, numericality: true, allow_blank: true

  validates :email, uniqueness: {case_sensitive: false, scope: :deleted_at }
  validates :document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }
  validates :phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true
  validates :unconfirmed_phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true
  
  validate :validates_postal_code
  validate :validates_phone_format
  validate :validates_unconfirmed_phone_format
  validate :validates_unconfirmed_phone_uniqueness

  def validates_postal_code
    if self.country == "ES"
      if (self.postal_code =~ /^\d{5}$/) != 0
        self.errors.add(:postal_code, "El código postal debe ser un número de 5 cifras")
      else
        province = Carmen::Country.coded("ES").subregions.coded(self.province)
        if province and self.postal_code[0...2] != province.subregions[0].code[2...4]
          self.errors.add(:postal_code, "El código postal no coincide con la provincia indicada")
        end
      end
    end
  end

  def validates_unconfirmed_phone_uniqueness
    if self.unconfirmed_phone.present? 
      if User.confirmed_phone.where(phone: self.unconfirmed_phone).exists? 
        self.update_attribute(:unconfirmed_phone, nil)
        self.errors.add(:phone, "Ya hay alguien con ese número de teléfono")
      end
    end
  end

  def validates_phone_format
    if self.phone.present? 
      self.errors.add(:phone, "Revisa el formato de tu teléfono") unless Phoner::Phone.valid?(self.phone) 
    end
  end

  def validates_unconfirmed_phone_format
    if self.unconfirmed_phone.present? 
      self.errors.add(:unconfirmed_phone, "Revisa el formato de tu teléfono") unless Phoner::Phone.valid?(self.unconfirmed_phone) 
      if self.country.downcase == "es" and not (self.unconfirmed_phone.starts_with?('00346') or self.unconfirmed_phone.starts_with?('00347'))
        self.errors.add(:unconfirmed_phone, "Debes poner un teléfono móvil válido de España empezando por 6 o 7.") 
      end
    end
  end

  def check_issue(validation_response, path, message, controller)
    if validation_response
      if message and validation_response.class == String
          message[message.first[0]] = validation_response
      end
      return {path: path, message: message, controller: controller}
    end
  end

  # returns issues with user profile, blocking first
  def get_unresolved_issue(only_blocking = false)

    # User has confirmed SMS code
    issue ||= check_issue self.sms_confirmed_at.nil?, :sms_validator_step1, { alert: "confirm_sms" }, "sms_validator"

    # User don't have a legacy password
    issue ||= check_issue self.has_legacy_password?, :new_legacy_password, { alert: "legacy_password" }, "legacy_password"

    # User have a valid born date
    issue ||= check_issue (self.born_at.nil? || (self.born_at == Date.civil(1900,1,1))), :edit_user_registration, { alert: "born_at"}, "registrations"

    # User must review his location (town code first letter uppercase)
    issue ||= check_issue self.town.starts_with?("M_"), :edit_user_registration, { notice: "location"}, "registrations"

    # User have a valid location
    issue ||= check_issue self.verify_user_location, :edit_user_registration, { alert: "location"}, "registrations"

    if issue || only_blocking  # End of blocking issues
      return issue
    end

    issue ||= check_issue self.vote_town_notice, :edit_user_registration, { notice: "vote_town"}, "registrations"

    if issue
      return issue
    end
  end


  attr_accessor :sms_user_token_given
  attr_accessor :login

  scope :all_with_deleted, -> { where "deleted_at IS null AND deleted_at IS NOT null"  }
  scope :users_with_deleted, -> { where "deleted_at IS NOT null"  }
  scope :wants_newsletter, -> {where(wants_newsletter: true)}
  scope :created, -> { where(deleted_at: nil)  }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :unconfirmed_mail, -> { where(confirmed_at: nil)  }
  scope :unconfirmed_phone, -> { where(sms_confirmed_at: nil) }
  scope :confirmed_mail, -> { where.not(confirmed_at: nil) }
  scope :confirmed_phone, -> { where.not(sms_confirmed_at: nil) }
  scope :legacy_password, -> { where(has_legacy_password: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil).where.not(sms_confirmed_at: nil) }
  scope :signed_in, -> { where.not(sign_in_count: nil) }
  scope :has_collaboration, -> { joins(:collaboration).where("collaborations.user_id IS NOT NULL") }
  scope :has_collaboration_credit_card, -> { joins(:collaboration).where('collaborations.payment_type' => 1) } 
  scope :has_collaboration_bank_national, -> { joins(:collaboration).where('collaborations.payment_type' => 2) }
  scope :has_collaboration_bank_international, -> { joins(:collaboration).where('collaborations.payment_type' => 3) }
  scope :wants_participation_team, -> { where(wants_participation: true) }

  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  # Based on 
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  # Check if login is email or document_vatid to use the DB indexes
  #
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      login_key = login.downcase.include?("@") ? "email" : "document_vatid"
      where(conditions).where(["lower(#{login_key}) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def get_or_create_vote election_id
    v = Vote.new({election_id: election_id, user_id: self.id})
    if Vote.find_by_voter_id( v.generate_message )
      return v 
    else
      v.save
      return v
    end
  end

  def document_vatid=(val)
    self[:document_vatid] = val.upcase.strip
  end

  def is_document_dni?
    self.document_type == 1
  end

  def is_document_nie?
    self.document_type == 2
  end

  def is_passport?
    self.document_type == 3
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def full_address
    "#{self.address}, #{self.town_name}, #{self.province_name}, CP #{self.postal_code}, #{self.country_name}"
  end

  def is_admin?
    self.admin
  end

  def is_valid_user?
    self.phone? and self.sms_confirmed_at?
  end

  def is_valid_phone?
    self.sms_confirmed_at? && self.sms_confirmed_at > self.confirmation_sms_sent_at || false
  end

  def can_change_phone?
    self.sms_confirmed_at? ? self.sms_confirmed_at < DateTime.now-3.months : true
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
    SMS::Sender.send_message(self.unconfirmed_phone, self.sms_confirmation_token)
  end

  def check_sms_token(token)
    if token == self.sms_confirmation_token
      self.update_attribute(:sms_confirmed_at, DateTime.now)
      if self.unconfirmed_phone? 
        self.update_attribute(:phone, self.unconfirmed_phone)
        self.update_attribute(:unconfirmed_phone, nil)
      end
      true
    else 
      false
    end
  end

  def phone_normalize(phone_number, country_iso=nil)
    Phoner::Country.load
    cc = country_iso.nil? ? self.country : country_iso
    country = Phoner::Country.find_by_country_isocode(cc.downcase)
    phoner = Phoner::Phone.parse(phone_number, :country_code => country.country_code)
    phoner.nil? ? nil : "00" + phoner.country_code + phoner.area_code + phoner.number
  end

  def unconfirmed_phone_number
    Phoner::Country.load
    country = Phoner::Country.find_by_country_isocode(self.country.downcase)
    if Phoner::Phone.valid?(self.unconfirmed_phone)
      phoner = Phoner::Phone.parse(self.unconfirmed_phone, :country_code => country.country_code)
      phoner.area_code + phoner.number
    else
      nil
    end
  end

  def phone_prefix 
    if self.country.length < 3 
      Phoner::Country.load
      begin
        Phoner::Country.find_by_country_isocode(self.country.downcase).country_code
      rescue
        "34"
      end
    else
      "34"
    end
  end

  def phone_country_name
    if Phoner::Phone.valid?(self.phone)
      Phoner::Country.load
      country_code = Phoner::Phone.parse(self.phone).country_code
      Carmen::Country.coded(Phoner::Country.find_by_country_code(country_code).char_3_code).name
    else
      Carmen::Country.coded(self.country).name
    end
  end

  def phone_no_prefix
    phone = Phoner::Phone.parse(self.phone)
    phone.area_code + phone.number
  end

  def document_type_name
    User::DOCUMENTS_TYPE.select{|v| v[1] == self.document_type }[0][0]
  end

  def country_name
    begin
      if self.country.length > 3 
        self.country
      else
        Carmen::Country.coded(self.country).name
      end
    rescue
      ""
    end
  end

  def province_name
    begin
      if self.province.length > 3 
        self.province
      else
        Carmen::Country.coded(self.country).subregions.coded(self.province).name
      end
    rescue
      ""
    end
  end

  def town_name
    begin
      if self.town.include? "_"
        Carmen::Country.coded(self.country).subregions.coded(self.province).subregions.coded(self.town.downcase).name
      else
        self.town
      end
    rescue
      ""
    end
  end

  def has_vote_town?
    not self.vote_town.nil? and not self.vote_town.empty? and not self.vote_town=="NOTICE"
  end

  def vote_province
    if self.has_vote_town?
      Carmen::Country.coded("ES").subregions[self.vote_town.split("_")[1].to_i-1].code
    else
      ""
    end
  end

  def vote_province= value
    if value.nil? or value.empty? or value == "-"
      self.vote_town = nil
    else
      prefix = "m_%02d_"% (Carmen::Country.coded("ES").subregions.coded(value).index+1)
      if self.vote_town.nil? or not self.vote_town.starts_with? prefix then
        self.vote_town = prefix
      end
    end
  end

  def vote_town_name
    Carmen::Country.coded("ES").subregions.coded(self.vote_province).subregions.coded(self.vote_town).name
  end

  def vote_province_name
    Carmen::Country.coded("ES").subregions.coded(self.vote_province).name
  end

  def vote_ca_name
    raise NotImplementedError
  end

  def vote_town_code
    if self.has_vote_town?
      self.vote_town.split("_")[1,3].join
    else
      ""
    end
  end

  def vote_province_code
    if self.has_vote_town?
      self.vote_town.split("_")[1]
    else
      "-"
    end
  end

  def vote_ca_code
    raise NotImplementedError
  end

  def verify_user_location()
    province = town = true
    country = Carmen::Country.coded(self.country)

    if not country then
      "country"

    elsif not country.subregions.empty? then
      province = country.subregions.coded(self.province)

      if not province then
        "province"
      elsif self.country == "ES" and not province.subregions.empty? then
        town = province.subregions.coded(self.town.downcase)
        if not town then
          "town"
        end
      end
    end
  end

  def vote_province_name
    if self.has_vote_town?
      Carmen::Country.coded("ES").subregions.coded(self.vote_province).name
    else
      ""
    end
  end

  def vote_town_name
    if self.has_vote_town?
      Carmen::Country.coded("ES").subregions.coded(self.vote_province).subregions.coded(self.vote_town).name
    else
      ""
    end
  end

  def vote_town_notice()
    self.country != "ES" and self.vote_town == "NOTICE"
  end

  def self.get_location(current_user, params)
    # params from edit page
    user_location = { country: params[:user_country], province: params[:user_province], town: params[:user_town], vote_town: params[:user_vote_town], vote_province: params[:user_vote_province] }

    # params from create page
    if params[:user]
      user_location[:country] ||= params[:user][:country]
      user_location[:province] ||= params[:user][:province]
      user_location[:town] ||= params[:user][:town]
      user_location[:vote_town] ||= params[:user][:vote_town]
      user_location[:vote_province] ||= params[:user][:vote_province]
    end

    # params from user profile
    if (params[:no_profile]==nil) && current_user
      user_location[:country] ||= current_user.country
      user_location[:province] ||= current_user.province
      user_location[:town] ||= current_user.town.downcase

      if current_user.has_vote_town?
        user_location[:vote_town] ||= current_user.vote_town
        user_location[:vote_province] ||= Carmen::Country.coded("ES").subregions.coded(current_user.vote_province).code
      else
        user_location[:vote_town] ||= "-"
        user_location[:vote_province] ||= "-"
      end
    end

    # default country
    user_location[:country] ||= "ES"

    user_location
  end

  def control_vote_town
    # Spanish users can't use a different town for vote
    if self.country=="ES"
      self.vote_town = self.town
    end
  end
  
  def users_with_deleted
    User.with_deleted
  end

  def admin_permalink
    admin_user_path(self)
  end

end
