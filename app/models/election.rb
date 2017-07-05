class Election < ActiveRecord::Base
  include FlagShihTzu

  SCOPE = [["Estatal", 0], ["Comunidad", 1], ["Provincial", 2], ["Municipal", 3], ["Insular", 4], ["Extranjeros", 5]]
  
  has_flags 1 => :requires_sms_check,
            2 => :show_on_index,
            3 => :ignore_multiple_territories,
            4 => :requires_vatid_check

  validates :title, :starts_at, :ends_at, :agora_election_id, :scope, presence: true
  has_many :votes
  has_many :election_locations, dependent: :destroy
 
  scope :active, -> { where("? BETWEEN starts_at AND ends_at", Time.now).order(priority: :asc)}
  scope :upcoming_finished, -> { where("ends_at > ? AND starts_at < ?", 2.days.ago, 12.hours.from_now).order(priority: :asc)}
  scope :future, -> { where("starts_at > ?", DateTime.now).order(priority: :asc)}

  before_create do |election|
    election[:counter_key] = SecureRandom.base64(20)
  end

  def counter_key
    self[:counter_key] || created_at.to_s
  end

  def to_s
    "#{title}"
  end

  def is_active?
    ( self.starts_at .. self.ends_at ).cover? DateTime.now
  end

  def is_upcoming?
    self.starts_at > DateTime.now and self.starts_at < 12.hours.from_now
  end

  def recently_finished?
    self.ends_at > 2.days.ago and self.ends_at < DateTime.now 
  end

  def scope_name
    SCOPE.select{|v| v[1] == self.scope }[0][0]
  end

  def user_version _user
    if self.user_created_at_max.nil?
      _user
    else
      prev_user = _user.version_at(self.user_created_at_max) 
      if prev_user && prev_user.has_vote_town?
        prev_user
      else
        _user
      end
    end
  end

  def full_title_for _user
    user = self.user_version(_user)
    if multiple_territories?
      suffix =  case self.scope
                  when 1 then " en #{user.vote_autonomy_name}"
                  when 2 then " en #{user.vote_province_name}"
                  when 3 then " en #{user.vote_town_name}"
                  when 4 then " en #{user.vote_island_name}"      
                end
      if not has_valid_location_for? user, false
        suffix = " (no hay votación#{suffix})"
      end
    end
    "#{self.title}#{suffix}"
  end

  def has_location_for? _user
    user = self.user_version(_user)
    not ((self.scope==5 and user.country=="ES") or (self.scope==4 and not user.vote_in_spanish_island?))
  end

  def has_valid_location_for? _user, check_created_at = true
    users = []
    return false if check_created_at && !has_valid_user_created_at?(_user)

    users << self.user_version(_user)
    users << _user unless check_created_at # allow to see election even when changed location

    users.any? do |user|
      case self.scope
        when 0 then self.election_locations.any?
        when 1 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_autonomy_numeric}
        when 2 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_province_numeric}
        when 3 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_town_numeric}
        when 4 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_island_numeric}
        when 5 then user.country!="ES" and self.election_locations.any?
      end
    end
  end

  def has_valid_user_created_at? user
    self.user_created_at_max.nil? or self.user_created_at_max > user.created_at
  end

  def current_total_census
    if self.user_created_at_max.nil?
      base = User.confirmed
    else
      base = User.with_deleted.where("deleted_at is null or deleted_at > ?", self.user_created_at_max).where.not(sms_confirmed_at:nil).where("created_at < ?", self.user_created_at_max)
    end
    if self.ignore_multiple_territories
      base.count
    else
      case self.scope
        when 0 then base.count
        when 1 then base.ransack( {vote_autonomy_in: self.election_locations.map {|l| "c_#{l.location}" } .join(",")}).result.count
        when 2 then base.ransack( {vote_province_in: self.election_locations.map {|l| "p_#{l.location}" } .join(",")}).result.count
        when 3 then base.where(vote_town: self.election_locations.map {|l| "m_#{l.location[0..1]}_#{l.location[2..4]}_#{l.location[5]}" }).count
        when 4 then base.ransack( {vote_island_in: self.election_locations.map {|l| "i_#{l.location}" } .join(",")}).result.count
        when 5 then base.where.not(country:"ES").count
      end
    end
  end

  def current_active_census
    if self.user_created_at_max.nil?
      base = User.confirmed.not_banned
      base_date = DateTime.now
    else
      base = User.with_deleted.not_banned.where("deleted_at is null or deleted_at > ?", self.user_created_at_max).where.not(sms_confirmed_at:nil).where("created_at < ?", self.user_created_at_max)
      base_date = self.user_created_at_max
    end
    base = base.where("current_sign_in_at > ?", base_date - eval(Rails.application.secrets.users["active_census_range"]) )

    if self.ignore_multiple_territories
      base.count
    else
      case self.scope
        when 0 then base.count
        when 1 then base.ransack( {vote_autonomy_in: self.election_locations.map {|l| "c_#{l.location}" } .join(",")}).result.count
        when 2 then base.ransack( {vote_province_in: self.election_locations.map {|l| "p_#{l.location}" } .join(",")}).result.count
        when 3 then base.where(vote_town: self.election_locations.map {|l| "m_#{l.location[0..1]}_#{l.location[2..4]}_#{l.location[5]}" }).count
        when 4 then base.ransack( {vote_island_in: self.election_locations.map {|l| "i_#{l.location}" } .join(",")}).result.count
        when 5 then base.where.not(country:"ES").count
      end
    end
  end

  def multiple_territories?
    !self.ignore_multiple_territories && self.scope.in?([1,2,3,4])
  end

  def scoped_agora_election_id _user
    user = self.user_version(_user)
    user_location = case self.scope
      when 1
        user.vote_autonomy_numeric
      when 2
        user.vote_province_numeric
      when 3
        user.vote_town_numeric
      when 4
        user.vote_island_numeric
      else
        "00"
    end
    election_location = self.election_locations.find_by_location user_location
    election_location.vote_id
  end

  def locations
    self.election_locations.map{|l| "#{l.location},#{l.agora_version}#{",#{l.override}" if l.override}"}.join "\n"
  end

  def locations= value
    ElectionLocation.transaction do
      value.split("\n").each do |line|
        if not line.strip.empty?
          line_raw = line.strip.split(',')
          location, agora_version, override = line_raw[0], line_raw[1], line_raw[2]
          self.election_locations.build(location: location, agora_version: agora_version, override: override).save
        end
      end
    end
  end

  def self.available_servers
    Rails.application.secrets.agora["servers"].keys
  end

  def server_shared_key
    server = Rails.application.secrets.agora["default"]
    server = self.server if self.server and !self.server.empty?
    Rails.application.secrets.agora["servers"][server]["shared_key"]
  end

  def server_url
    server = Rails.application.secrets.agora["default"]
    server = self.server if self.server and !self.server.empty?
    Rails.application.secrets.agora["servers"][server]["url"]
  end

  def duration
    ((ends_at-starts_at)/60/60).to_i
  end

  def votes_histogram
    xbin_size = 60*10 # 10 minutes
    ybin_size = 60*60*24 # 1 hour
    data = self.votes.joins(:user).pluck(:created_at, "users.created_at")
    data = data.group_by do |v,u| [v.to_i/xbin_size, u.to_i/ybin_size] end .map {|k,v| [k[0]*xbin_size+xbin_size/2, k[1]*ybin_size+ybin_size/2, v.count] }
    { data: data, limits: [ [ data.map(&:first).min, data.map(&:first).max], [ data.map(&:second).min, data.map(&:second).max ] ] }
  end

  def valid_votes_count
    votes.with_deleted.where("deleted_at is null or deleted_at>?", ends_at).select(:user_id).distinct.count
  end

  def counter_hash
    Base64::strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new('sha256'), counter_key, "#{created_at.to_i} #{id}"))[0..16]
  end

  def validate_hash _hash
    counter_hash == _hash
  end

  def external?
    external_link.present?
  end
end
