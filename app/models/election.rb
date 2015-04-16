class Election < ActiveRecord::Base

  SCOPE = [["Estatal", 0], ["Comunidad", 1], ["Provincial", 2], ["Municipal", 3], ["Insular", 4], ["Extranjeros", 5]]
  
  validates :title, :starts_at, :ends_at, :agora_election_id, :scope, presence: true
  has_many :votes
  has_many :election_locations
 
  scope :active, -> { where("? BETWEEN starts_at AND ends_at", Time.now)}
  scope :upcoming_finished, -> { where("ends_at > ? AND starts_at < ?", 2.days.ago, 12.hours.from_now)}

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

  def full_title_for user
    if multiple_territories?
      suffix =  case self.scope
                  when 1 then " en #{user.vote_autonomy_name}"
                  when 2 then " en #{user.vote_province_name}"
                  when 3 then " en #{user.vote_town_name}"
                  when 4 then " en #{user.vote_island_name}"      
                end
      if not has_valid_location_for? user
        suffix = " (no hay votación#{suffix})"
      end
    end
    "#{self.title}#{suffix}"
  end

  def has_location_for? user
    not ((self.scope==5 and user.country=="ES") or (self.scope==4 and not user.vote_in_spanish_island?))
  end

  def has_valid_location_for? user
    case self.scope
      when 0 then true
      when 1 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_autonomy_numeric}
      when 2 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_province_numeric}
      when 3 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_town_numeric}
      when 4 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_island_numeric}
      when 5 then user.country!="ES"
    end
  end

  def current_total_census
    case self.scope
      when 0 then User.confirmed.count
      when 1 then User.confirmed.ransack( {vote_autonomy_in: Election.last.election_locations.map {|l| "c_#{l.location}" }}).result.count
      when 2 then User.confirmed.ransack( {vote_province_in: Election.last.election_locations.map {|l| "p_#{l.location}" }}).result.count
      when 3 then User.confirmed.where(vote_town: Election.last.election_locations.map {|l| "m_#{l.location[0..1]}_#{l.location[2..4]}_#{l.location[5]}" })
      when 4 then User.confirmed.ransack( {vote_island_in: Election.last.election_locations.map {|l| "i_#{l.location}" }}).result.count
      when 5 then User.confirmed.where.not(country:"ES").count
    end
  end

  def multiple_territories?
    [1,2,3,4].member? self.scope
  end

  def scoped_agora_election_id user
    case self.scope
      when 0 
        location = self.election_locations.find_by_location "00"
        (self.agora_election_id.to_s + "00" + location.agora_version.to_s).to_i
      when 1
        location = self.election_locations.find_by_location user.vote_autonomy_numeric
        (self.agora_election_id.to_s + user.vote_autonomy_numeric.to_s + location.agora_version.to_s).to_i
      when 2
        location = self.election_locations.find_by_location user.vote_province_numeric
        (self.agora_election_id.to_s + user.vote_province_numeric.to_s + location.agora_version.to_s).to_i
      when 3
        location = self.election_locations.find_by_location user.vote_town_numeric
        (self.agora_election_id.to_s + user.vote_town_numeric.to_s + location.agora_version.to_s).to_i
      when 4
        location = self.election_locations.find_by_location user.vote_island_numeric
        (self.agora_election_id.to_s + user.vote_island_numeric.to_s + location.agora_version.to_s).to_i
      when 5
        location = self.election_locations.find_by_location "00"
        (self.agora_election_id.to_s + "00" + location.agora_version.to_s).to_i
    end
  end

  def locations
    self.election_locations.map{|e| "#{e.location},#{e.agora_version}" }.join "\n"
  end

  def locations= value
    ElectionLocation.transaction do
      self.election_locations.destroy_all
      value.split("\n").each do |line|
        if not line.strip.empty?
          line_raw = line.strip.split(',')
          location, agora_version = line_raw[0], line_raw[1]
          self.election_locations.build(location: location, agora_version: agora_version).save
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
end
