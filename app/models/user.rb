class User < ActiveRecord::Base
  apply_simple_captcha

  include FlagShihTzu

  include Rails.application.routes.url_helpers

  has_flags  1 => :banned,
             2 => :superadmin,
             3 => :verified,
             4 => :finances_admin,
             5 => :impulsa_author,
             6 => :impulsa_admin,
             7 => :verifier,
             8 => :paper_authority,
             9 => :militant,
            10 => :exempt_from_payment

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  before_validation :check_unconfirmed_phone
  before_update :_clear_caches
  before_save :before_save

  acts_as_paranoid
  has_paper_trail

  has_many :votes, dependent: :destroy
  has_many :paper_authority_votes, dependent: :nullify, class_name: "Vote", inverse_of: :paper_authority

  has_many :supports, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_and_belongs_to_many :participation_team
  has_many :microcredit_loans
  has_many :user_verifications
  has_many :militant_records

  belongs_to :vote_circle

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :address, :postal_code, :town, :province, :country, :born_at, presence: true
  validates :email, email: true
  validates :email, confirmation: true, on: :create
  validates :email_confirmation, presence: true, on: :create
  validates :terms_of_service, acceptance: true
  validates :over_18, acceptance: true
  validates :document_type, inclusion: { in: [1, 2, 3], message: "Tipo de documento no válido" }
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, date: true, allow_blank: true # gem date_validator
  validate :validate_born_at
  validates :checked_vote_circle, acceptance: true

  validates :email, uniqueness: {case_sensitive: false, scope: :deleted_at }
  validates :document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }
  validates :phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true
  validates :unconfirmed_phone, uniqueness: {scope: :deleted_at}, allow_blank: true, allow_nil: true

  validate :validates_postal_code
  validate :validates_phone_format
  validate :validates_unconfirmed_phone_format
  validate :validates_unconfirmed_phone_uniqueness

  MIN_MILITANT_AMOUNT = Rails.application.secrets.users["min_militant_amount"].present? ? Rails.application.secrets.users["min_militant_amount"].to_i : 3

  def validate_born_at
    errors.add(:born_at, "debes ser mayor de 18 años") if born_at && born_at > Date.today - 18.years
  end

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
        self.errors.add(:phone, "Ya hay alguien con ese número de teléfono")
      end
    end
  end

  def validates_phone_format
    if self.phone.present?
      _phone = Phonelib.parse self.phone.sub(/^00+/, '+')
      if _phone.invalid? || _phone.impossible?
        self.errors.add(:phone, "Revisa el formato de tu teléfono")
      elsif (_phone.possible_types & [:fixed_line, :mobile, :fixed_or_mobile]).none?
        self.errors.add(:phone, "Debes utilizar un teléfono móvil")
      else
        self.phone = "00"+_phone.international(false)
      end
    end
  end

  def validates_unconfirmed_phone_format
    if self.unconfirmed_phone.present?
      _phone = Phonelib.parse self.unconfirmed_phone.sub(/^00+/, '+')

      if _phone.invalid? || _phone.impossible?
        self.errors.add(:unconfirmed_phone, "Revisa el formato de tu teléfono")
      elsif _phone.invalid_for_country?("ES") && _phone.invalid_for_country?(self.country)
        self.errors.add(:unconfirmed_phone, "Debes utilizar un teléfono de España o del país donde vives")
      elsif (_phone.possible_types & [:mobile, :fixed_or_mobile]).none?
        self.errors.add(:unconfirmed_phone, "Debes utilizar un teléfono móvil")
      else
        self.unconfirmed_phone = "00"+_phone.international(false)
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

    # User have a valid born date
    issue ||= check_issue (self.born_at.nil? || (self.born_at == Date.civil(1900,1,1))), :edit_user_registration, { alert: "born_at"}, "registrations"

    # User must review his location (town code first letter uppercase)
    issue ||= check_issue self.town.starts_with?("M_"), :edit_user_registration, { notice: "location"}, "registrations"

    # User have a valid location
    issue ||= check_issue self.verify_user_location, :edit_user_registration, { alert: "location"}, "registrations"

    # User don't have a legacy password, verify if profile is valid before request to change it
    if self.has_legacy_password?
      issue ||= check_issue self.invalid?, :edit_user_registration, nil, "registrations"

      issue ||= check_issue true, :new_legacy_password, { alert: "legacy_password" }, "legacy_password"
    end

    # User has confirmed SMS code
    issue ||= check_issue self.sms_confirmed_at.nil?, :sms_validator_step1, { alert: "confirm_sms" }, "sms_validator"

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
  attr_accessor :skip_before_save
  attr_accessor :checked_vote_circle
  attr_accessor :participa_user_id

  scope :all_with_deleted, -> { where "deleted_at IS null OR deleted_at IS NOT null"  }
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
  scope :has_collaboration, -> { joins(:collaborations).where("collaborations.user_id IS NOT NULL") }
  scope :has_collaboration_credit_card, -> { joins(:collaborations).where('collaborations.payment_type' => 1) }
  scope :has_collaboration_bank_national, -> { joins(:collaborations).where('collaborations.payment_type' => 2) }
  scope :has_collaboration_bank_international, -> { joins(:collaborations).where('collaborations.payment_type' => 3) }
  scope :participation_team, -> { includes(:participation_team).where.not(participation_team_at: nil) }
  scope :has_vote_circle, -> { where("vote_circle_id IS NOT NULL") }
  scope :wants_information_by_sms, -> {where(wants_information_by_sms: true)}
  scope :militant_and_exempt_from_payment, -> {created.militant.exempt_from_payment}
  scope :active_militant, -> {created.militant}
  scope :exterior, -> { where.not(country: "ES") }
  scope :spain, -> { where(country: "ES") }

  ransacker :vote_province, formatter: proc { |value|
    values = value.split(",")
    values.map {|val| Carmen::Country.coded("ES").subregions[(val[2..3].to_i-1)].subregions.map {|r| r.code } } .flatten.compact
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_autonomy, formatter: proc { |value|
    values = value.split(",")
    spain = Carmen::Country.coded("ES")
    Podemos::GeoExtra::AUTONOMIES.map { |k,v| spain.subregions[k[2..3].to_i-1].subregions.map {|r| r.code } if v[0].in?(values) } .compact.flatten
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_island, formatter: proc { |value|
    values = value.split(",")
    Podemos::GeoExtra::ISLANDS.map {|k,v| k if v[0].in?(values)} .compact
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :user_vote_circle_province_id, formatter: proc { |value|
    VoteCircle.where("code like ?", value).map { |vote_circle| vote_circle.id }.uniq
   } do |parent|
    parent.table[:vote_circle_id]
  end

  ransacker :user_vote_circle_autonomy_id, formatter: proc { |value|
    VoteCircle.where("code like ?", value).map { |vote_circle| vote_circle.id }.uniq
   } do |parent|
     parent.table[:vote_circle_id]
  end

  ransacker :user_vote_circle_id, formatter: proc { |value|
    VoteCircle.where(id: value).map { |vote_circle| vote_circle.id }.uniq
  } do |parent|
    parent.table[:vote_circle_id]
  end

  GENDER = { "F" => "Femenino", "M" => "Masculino", "O" => "Otro", "N" => "No contesta" }
  DOCUMENTS_TYPE = [["DNI", 1], ["NIE", 2], ["Pasaporte", 3]]

  # Based on
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  # Check if login is email or document_vatid to use the DB indexes
  #
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      login_key = login.downcase.include?("@") ? "email" : "document_vatid"
      where(conditions).where(["lower(#{login_key}) = :value", { :value => login.downcase }]).take
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

  def has_already_voted_in election_id
    Vote.where(election_id: election_id).where(user_id:self.id).present?
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

  def is_valid_phone?
    self.phone? and self.confirmation_sms_sent_at? and self.sms_confirmed_at? and self.sms_confirmed_at > self.confirmation_sms_sent_at
  end

  def can_change_phone?
    self.sms_confirmed_at.nil? or self.sms_confirmed_at < DateTime.now-3.months
  end

  def self.blocked_provinces
    Rails.application.secrets.users["blocked_provinces"]
  end

  def can_change_vote_location?
    # use database version if vote_town has changed
    !self.has_verified_vote_town? or !self.persisted? or
      (Rails.application.secrets.users["allows_location_change"] and !User.blocked_provinces.member?(vote_province_persisted))
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

        if not self.verified? and not self.is_admin?
          filter = SpamFilter.any? self
          if filter
            self.update_attribute(:banned, true)
            self.add_comment("Usuario baneado automáticamente por el filtro: #{filter}")
          end
        end
      end
      true
    else
      false
    end
  end

  def unconfirmed_phone= value
    _phone = Phonelib.parse(value, self.country)
    _phone = Phonelib.parse(value, "ES") if (_phone.invalid? || (_phone.possible_types & [:mobile, :fixed_or_mobile]).empty?) && self.country!="ES"
    if _phone.valid? && (_phone.possible_types & [:mobile, :fixed_or_mobile]).any?
      self[:unconfirmed_phone] = "00"+_phone.international(false)
    else
      self[:unconfirmed_phone] = value
      self.errors.add(:unconfirmed_phone, "Debes utilizar un teléfono móvil de España o del país donde vives")
    end
  end

  def unconfirmed_phone_national_part
    extract_national_part(self.unconfirmed_phone) if self.unconfirmed_phone.present?
  end

  def phone_national_part
    extract_national_part(self.phone) if self.phone.present?
  end

  def country_phone_prefix
    begin
      Phonelib.phone_data[self.country][:country_code]
    rescue
      "34"
    end
  end

  def phone_prefix
    ret = self.country_phone_prefix
    if self.phone.present?
      _phone = Phonelib.parse(self.phone.sub(/^00+/, '+'))
      ret = _phone.country_code.to_s if _phone && _phone.country_code
    end
    ret
  end

  def phone_country_name
    _phone = Phonelib.parse(self.phone)
    _country = Carmen::Country.coded(_phone.country) if _phone.country

    if _country
      _country.name
    else
      "País desconocido"
    end
  end

  def document_type_name
    User::DOCUMENTS_TYPE.select{|v| v[1] == self.document_type }[0][0]
  end

  def gender_name
    User::GENDER[self.gender]
  end

  def in_spain?
    self.country=="ES"
  end

  def country_name
    if _country
      _country.name
    else
      self.country or ""
    end
  end

  def province_name
    if _province
      _province.name
    else
      self.province or ""
    end
  end

  def province_code
    if self.in_spain? and _province
      "p_%02d" % + _province.index
    else
      ""
    end
  end

  def town_name
    if self.in_spain? and _town
      _town.name
    else
      self.town or ""
    end
  end

  def autonomy_code
    if self.in_spain? and _province
      Podemos::GeoExtra::AUTONOMIES[self.province_code][0]
    else
      ""
    end
  end

  def autonomy_name
    if self.in_spain? and _province
      Podemos::GeoExtra::AUTONOMIES[self.province_code][1]
    else
      ""
    end
  end

  def island_code
    if self.in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.town][0]
    else
      ""
    end
  end

  def island_name
    if self.in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.town][1]
    else
      ""
    end
  end

  def in_spanish_island?
    (self.in_spain? and Podemos::GeoExtra::ISLANDS.has_key? self.town) or false
  end

  def vote_in_spanish_island?
    (Podemos::GeoExtra::ISLANDS.has_key? self.vote_town) or false
  end

  def has_vote_town?
    self.vote_town.present? && self.vote_town[0].downcase=="m" && (1..52).include?(self.vote_town[2,2].to_i)
  end

  def has_verified_vote_town?
    self.has_vote_town? && self.vote_town[0]=="m"
  end

  def vote_autonomy_code
    if _vote_province
      Podemos::GeoExtra::AUTONOMIES[self.vote_province_code][0]
    else
      ""
    end
  end

  def vote_autonomy_name
    if _vote_province
      Podemos::GeoExtra::AUTONOMIES[self.vote_province_code][1]
    else
      ""
    end
  end

  def vote_town_name
    if _vote_town
      _vote_town.name
    else
      ""
    end
  end

  def vote_province_persisted
    prov = _vote_province
    if self.vote_town_changed?
      begin
        previous_province = Carmen::Country.coded("ES").subregions[self.vote_town_was[2,2].to_i-1]
        prov = previous_province if previous_province
      rescue
      end
    end

    if prov
      prov.code
    else
      ""
    end
  end

  def vote_province
    if _vote_province
      _vote_province.code
    else
      ""
    end
  end

  def vote_province= value
    if value.nil? or value.empty? or value == "-"
      self.vote_town = nil
    else
      prefix = "m_%02d_"% (Carmen::Country.coded("ES").subregions.coded(value).index)
      if self.vote_town.nil? or not self.vote_town.starts_with? prefix then
        self.vote_town = prefix
      end
    end
  end

  def vote_province_code
    if _vote_province
      "p_%02d" % + _vote_province.index
    else
      ""
    end
  end

  def vote_province_name
    if _vote_province
      _vote_province.name
    else
      ""
    end
  end


  def vote_island_code
    if self.vote_in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.vote_town][0]
    else
      ""
    end
  end

  def vote_island_name
    if self.vote_in_spanish_island?
      Podemos::GeoExtra::ISLANDS[self.vote_town][1]
    else
      ""
    end
  end

  def vote_autonomy_numeric
    if _vote_province
      self.vote_autonomy_code[2..-1]
    else
      "-"
    end
  end

  def vote_province_numeric
    if _vote_province
      "%02d" % + _vote_province.index
    else
      ""
    end
  end

  def vote_town_numeric
    if _vote_town
      _vote_town.code.split("_")[1,3].join
    else
      ""
    end
  end

  def vote_island_numeric
    if self.vote_in_spanish_island?
      self.vote_island_code[2..-1]
    else
      ""
    end
  end

  def verify_user_location()
    return "country" if not _country
    return "province" if not _country.subregions.empty? and not _country.subregions.coded(self.province)
    return "town" if self.in_spain? and not _town
  end

  def vote_town_notice()
    self.vote_town == "NOTICE"
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
    if (params[:no_profile]==nil) && current_user && current_user.persisted?
      user_location[:country] ||= current_user.country
      user_location[:province] ||= current_user.province
      user_location[:town] ||= current_user.town.downcase

      if current_user.has_vote_town? && current_user.vote_province
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

  def self.ban_users ids, value
    t = User.with_deleted.arel_table
    User.with_deleted.where(id:ids).where(t[:admin].eq(false).or(t[:admin].eq(nil))).update_all User.set_flag_sql(:banned, value)
  end

  def before_save
    unless @skip_before_save
      # Spanish users can't set a different town for vote, except when blocked
      if self.in_spain? and self.can_change_vote_location?
        self.vote_town = self.town
        self.vote_district = nil if self.vote_town_changed? # remove this when the user is allowed to choose district
      end
      self.militant = self.still_militant?
      if self.vote_circle_id_changed?
        self.vote_circle_changed_at = Time.now
        process_militant_data
      end
      true
    end
  end

  def in_participation_team? team_id
    self.participation_team_ids.member? team_id
  end

  def admin_permalink
    admin_user_path(self)
  end

  def _clear_caches
    remove_instance_variable :@country_cache if defined? @country_cache
    remove_instance_variable :@province_cache if defined? @province_cache
    remove_instance_variable :@town_cache if defined? @town_cache
    remove_instance_variable :@vote_province_cache if defined? @vote_province_cache
    remove_instance_variable :@vote_town_cache if defined? @vote_town_cache
  end

  def _country
    @country_cache ||= Carmen::Country.coded(self.country)
  end

  def _province
    @province_cache = begin
      prov = nil
      prov = _country.subregions[self.town[2,2].to_i-1] if self.in_spain? and self.town and self.town.downcase.starts_with? "m_"
      prov = _country.subregions.coded(self.province) if prov.nil? and _country and self.province and not _country.subregions.empty?
      prov
    end if not defined? @province_cache
    @province_cache
  end

  def _town
    @town_cache = begin
      town = nil
      town = _province.subregions.coded(self.town) if self.in_spain? and _province
      town
    end if not defined? @town_cache
    @town_cache
  end

  def _vote_province
    @vote_province_cache = begin
      prov = nil
      if self.has_vote_town?
        prov = Carmen::Country.coded("ES").subregions[self.vote_town[2,2].to_i-1]
      elsif self.country=="ES"
        prov = _province
      else
        prov = nil
      end
      prov
    end if not defined? @vote_province_cache
    @vote_province_cache
  end

  def _vote_town
    @vote_town_cache = begin
      town = nil
      if self.has_vote_town? && _vote_province
        town = _vote_province.subregions.coded(self.vote_town)
      elsif self.country=="ES"
        town = _town
      else
        prov = nil
      end
      town
    end if not defined? @vote_town_cache
    @vote_town_cache
  end

  def can_request_sms_check?
    DateTime.now > next_sms_check_request_at
  end

  def can_check_sms_check?
    sms_check_at.present? && (DateTime.now < (sms_check_at + eval(Rails.application.secrets.users["sms_check_valid_interval"])))
  end

  def next_sms_check_request_at
    if sms_check_at.present?
      sms_check_at + eval(Rails.application.secrets.users["sms_check_request_interval"])
    else
      DateTime.now - 1.second
    end
  end

  def send_sms_check!
    require 'sms'
    if can_request_sms_check?
      self.update_attribute(:sms_check_at, DateTime.now)
      SMS::Sender.send_message(self.phone, self.sms_check_token)
      true
    else
      false
    end
  end

  def valid_sms_check? value
    sms_check_at and value.upcase == sms_check_token
  end

  def sms_check_token
    Digest::SHA1.digest("#{sms_check_at}#{id}#{Rails.application.secrets.users['sms_secret_key'] }")[0..3].codepoints.map { |c| "%02X" % c }.join if sms_check_at
  end

  def pass_vatid_check?
    self.verified || self.user_verifications.pending.any?
  end

  def urban_vote_town?
    self.vote_town.present? && Podemos::GeoExtra::URBAN_TOWNS.member?(self.vote_town)
  end

  def semi_urban_vote_town?
    self.vote_town.present? && Podemos::GeoExtra::SEMI_URBAN_TOWNS.member?(self.vote_town)
  end

  def rural_vote_town?
    !self.urban_vote_town? && !self.semi_urban_vote_town?
  end

  def has_not_future_verified_elections?
    !self.has_future_verified_elections?
  end

  def has_future_verified_elections?
    Election.future.requires_vatid_check.any? { |e| e.has_valid_location_for? self}
  end

  def has_not_verification_accepted?
     UserVerification.where(
       user_id: self.id,
       status: [UserVerification::statuses[:accepted],UserVerification::statuses[:accepted_by_email]]
     ).blank?
  end

  def imperative_verification
    return if verified? || !has_future_verified_elections?

    UserVerification.find_by(
      user_id: self.id,
      status: %w(pending issues paused).map {|status| UserVerification::statuses[status] }
    )
  end

  def photos_unnecessary?
    self.has_future_verified_elections? && self.verified && (UserVerification.where(user_id:self.id).none? || UserVerification.accepted_by_email.where(user_id: self.id).any?)
  end
  def photos_necessary?
    self.has_future_verified_elections? && !self.verified  || (UserVerification.where(user_id: self.id).any? && UserVerification.accepted_by_email.where(user_id: self.id).none?)
  end

  def vote_autonomy_since
    last_vote_location_change[:autonomy]
  end

  def vote_province_since
    last_vote_location_change[:province]
  end

  def vote_island_since
    last_vote_location_change[:island]
  end

  def vote_town_since
    last_vote_location_change[:town]
  end

  def any_microcredit_renewable?
    MicrocreditLoan.renewables.where(document_vatid: self.document_vatid).exists?
  end

  def recurrent_collaboration
    collaborations.where.not(frequency: 0).last
  end

  def single_collaboration
    collaborations.where(frequency: 0).last
  end

  def pending_single_collaborations
    collaborations.where(frequency: 0).where(status:2)
  end

  def sendy_url
    url = "#{Rails.application.secrets.users["sendy_page"]}?zaz="
    url+= encrypt_data(email)
  end

  def can_change_vote_circle?
    # use database version if vote_town has changed
    has_limit_date = Rails.application.secrets.users["date_close_vote_circle_unlimited_changes"].present?
    return true unless has_limit_date && Time.zone.now >=Time.zone.parse(Rails.application.secrets.users["date_close_vote_circle_unlimited_changes"])
    return true unless self.vote_circle.present? && self.vote_circle.is_active?
    max = Rails.application.secrets.users["allow_vote_circle_changed_at_days"].present? ? Rails.application.secrets.users["allow_vote_circle_changed_at_days"].to_i.days: 365
    return true unless self.vote_circle_changed_at.present?
    reset_date = Rails.application.secrets.users["reset_vote_circle_changed_at"] if Rails.application.secrets.users["reset_vote_circle_changed_at"].present?
    (reset_date.present? && Time.zone.parse(self.vote_circle_changed_at.to_s) <= (Time.zone.parse(reset_date)))||(Time.zone.parse(self.vote_circle_changed_at.to_s) <= (Time.zone.now - max.days)) || !self.persisted?
  end

  def in_vote_circle?
    self.vote_circle_id.present?
  end

  def has_min_monthly_collaboration?
    self.collaborations.where.not(frequency:0).where("amount >= ?", MIN_MILITANT_AMOUNT).where(status:3).exists?
  end

  def verified_for_militant?
    status = self.user_verifications.last.status if self.user_verifications.any?
    self.verified? || (self.user_verifications.any? && (status == "pending" || status == "accepted" || status == "accepted_by_email"))
  end

  def collaborator_for_militant?
    (self.has_min_monthly_collaboration? || self.collaborations.where.not(frequency:0).where("amount >= ?", MIN_MILITANT_AMOUNT).where(status:2).exists?)
  end

  def still_militant?
    self.verified_for_militant? && self.in_vote_circle? && (self.exempt_from_payment? || self.collaborator_for_militant?)
  end

  def militant_at?(date)
    in_circle_at = Time.zone.parse(self.vote_circle_changed_at.to_s) if self.vote_circle_id.present?
    verified_at = nil
    collaborator_at = nil
    if self.user_verifications.any?
      last_verification = self.user_verifications.last
      status = last_verification.status
      verified_at = Time.zone.parse(last_verification.updated_at.to_s) if self.verified? || (status == "pending" || status == "accepted")
    end
    valid_collaboration = self.collaborations.where.not(frequency:0).where("amount >= ?", MIN_MILITANT_AMOUNT).where(status:[0, 2,3])
    if valid_collaboration.exists?
      collaborator_at = Time.zone.parse(valid_collaboration.last.created_at.to_s)
    end
    if self.exempt_from_payment?
      last_record = MilitantRecord.where(user_id:self.id).where(payment_type:0).where.not(begin_payment:nil).last
      exempt_at = Time.zone.parse(last_record.begin_payment.to_s) if last_record.present? && last_record.begin_payment.present?
      collaborator_at = [collaborator_at, exempt_at].min if collaborator_at && exempt_at
      collaborator_at ||= exempt_at
    end

    return false unless in_circle_at.present? && verified_at.present? && collaborator_at.present?
    dates_1 = [in_circle_at, collaborator_at]
    min_date =Time.zone.parse(date.to_s)
    (dates_1.min <= min_date)
  end

  def get_not_militant_detail
    is_militant = self.still_militant?
    return if self.militant? && is_militant
    self.update(militant:is_militant) && return if is_militant
    result =[]

    result.push("No esta verificado") unless self.verified_for_militant?
    result.push("No esta inscrito en un circulo") unless self.in_vote_circle?
    result.push("No tiene colaboración económica periódica suscrita, no está exento de pago") unless self.exempt_from_payment? || self.collaborator_for_militant?
    result.compact.flatten.join(", ").sub(/.*\K, /, ' y ')
  end

  def militant_records_management(is_militant)
    last_record = self.militant_records.last if self.militant_records.any?
    last_record ||= MilitantRecord.new
    new_record = MilitantRecord.new
    new_record.user_id = self.id
    now = DateTime.now
    if self.verified_for_militant?
      new_record.begin_verified = last_record.begin_verified unless last_record.end_verified.present?
      new_record.begin_verified ||= self.user_verifications.pluck(:updated_at).last
      new_record.end_verified = nil
    else
      new_record.begin_verified = last_record.begin_verified || nil
      new_record.end_verified = now if new_record.begin_verified.present?
    end
    if self.in_vote_circle?
      if self.vote_circle && self.vote_circle.name.present? && last_record.vote_circle_name.present? && self.vote_circle.name.downcase.strip == last_record.vote_circle_name.downcase.strip
        new_record.begin_in_vote_circle = last_record.begin_in_vote_circle unless last_record.end_in_vote_circle.present?
        new_record.begin_in_vote_circle ||= self.vote_circle_changed_at
        new_record.vote_circle_name = last_record.vote_circle_name if last_record.vote_circle_name.present? && last_record.end_in_vote_circle.nil?
        new_record.vote_circle_name ||= self.vote_circle.name
        new_record.end_in_vote_circle = nil
      else
        last_record.update(end_in_vote_circle:self.vote_circle_changed_at)
        new_record.begin_in_vote_circle = self.vote_circle_changed_at
        new_record.vote_circle_name = self.vote_circle.name
        new_record.end_in_vote_circle = nil
      end
    else
      new_record.begin_in_vote_circle = last_record.begin_in_vote_circle if last_record.begin_in_vote_circle.present?
      new_record.vote_circle_name = last_record.vote_circle_name if last_record.vote_circle_name.present?
      new_record.end_in_vote_circle = now if new_record.begin_in_vote_circle.present?
    end
    if self.exempt_from_payment? || self.collaborator_for_militant?
      date_collaboration = last_record.begin_payment unless  last_record.end_payment.present?
      new_record.payment_type = last_record.payment_type unless last_record.end_payment.present?
      if self.exempt_from_payment?
        date_collaboration ||= now
        new_record.payment_type ||= 0
        new_record.amount = 0
      else
        last_valid_collaboration = self.collaborations.where.not(frequency:0).where("amount >= ?", MIN_MILITANT_AMOUNT).where(status:3).last
        last_valid_collaboration ||= self.collaborations.where.not(frequency:0).where(status:[0, 2]).last
        date_collaboration ||= last_valid_collaboration.created_at
        new_record.payment_type ||= 1
        new_record.amount = last_valid_collaboration.amount
      end
      new_record.begin_payment = date_collaboration
      new_record.end_payment = nil
    else
      new_record.begin_payment = last_record.begin_payment if last_record.begin_payment.present?
      new_record.end_in_vote_circle = now if new_record.begin_payment.present?
    end
    new_record.is_militant = is_militant
    new_record.save if new_record.diff?(last_record)
  end

  def process_militant_data
    is_militant = self.still_militant?
    lmr = self.militant_records.last
    UsersMailer.new_militant_email(self.id).deliver_now  if is_militant && (lmr.blank? || (lmr.present? && lmr.is_militant == false))
    self.militant_records_management is_militant
  end

  def self.census_vote_circle
    ids = User.militant.select{ |u| u.id if u.militant_at?('2020-09-15')}
    User.where(id:ids)
  end
  private

  def last_vote_location_change
    @last_vote_location_change ||= begin
      ret = {
        autonomy: updated_at,
        province: updated_at,
        island: updated_at,
        town: updated_at
      }

      if vote_town
        changed_autonomy = changed_province = changed_town = false
        changed_island = !in_spanish_island?

        versions.reverse_each do |v|
          old_user = v.reify

          break unless old_user

          ret[:autonomy] = v.created_at unless changed_autonomy
          ret[:province] = v.created_at unless changed_province
          ret[:island] = v.created_at unless changed_island
          ret[:town] = v.created_at unless changed_town

          changed_autonomy ||= old_user.vote_autonomy_code != vote_autonomy_code
          changed_province ||= old_user.vote_province_code != vote_province_code
          changed_island ||= old_user.vote_island_code != vote_island_code
          changed_town ||= old_user.vote_town.blank? || !old_user.vote_town.casecmp(vote_town).zero?

          break if changed_autonomy && changed_province && changed_town && changed_island
        end
      end

      ret
    end
  end

  def extract_national_part(the_phone)
    phone_obj = Phonelib.parse(the_phone)
    phone_obj.international(false).sub(/^#{phone_obj.country_code}/, "")
  end
  
  def check_unconfirmed_phone
    self[:unconfirmed_phone] = nil if self.unconfirmed_phone.present? && self.country_changed?
  end

  def encrypt_data(data)
    cipher_type = Rails.application.secrets.users["cipher_type"]
    key = Rails.application.secrets.users["cipher_key"]
    iv = Rails.application.secrets.users["cipher_iv"]

    cipher = OpenSSL::Cipher.new(cipher_type)
    cipher.encrypt
    cipher.key=key
    cipher.iv=iv

    encrypted = cipher.update(data)+ cipher.final
    Base64.encode64([encrypted].pack('m').chomp)
  end
end
