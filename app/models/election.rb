class Election < ActiveRecord::Base

  SCOPE = [["Estatal", 0], ["Comunidad", 1], ["Provincial", 2], ["Municipal", 3]]
  
  validates :title, :starts_at, :ends_at, :agora_election_id, :scope, presence: true
  has_many :votes
  has_many :election_locations

  scope :actived, -> { where("? BETWEEN starts_at AND ends_at", Time.now)}

  def is_actived?
    ( self.starts_at .. self.ends_at ).cover? DateTime.now
  end

  def recently_finished?
    # Devuelve true si ha finalizado en menos de 7 días
    self.ends_at < DateTime.now and self.ends_at > 7.days.ago
  end

  def has_valid_location_for? user
    case self.scope
      when 0 then true
      when 1 then self.election_locations.exists?(location: user.vote_ca_code)
      when 2 then self.election_locations.exists?(location: user.vote_province_code)
      when 3 then self.election_locations.exists?(location: user.vote_town_code)
    end
  end

  def scope_name
    SCOPE.select{|v| v[1] == self.scope }[0][0]
  end

  def scoped_agora_election_id user
    case self.scope
      when 0 then self.agora_election_id
      when 1 then (self.agora_election_id.to_s + user.vote_ca_code).to_i
      when 2 then (self.agora_election_id.to_s + user.vote_province_code).to_i
      when 3 then user.vote_town_code.to_i #(self.agora_election_id.to_s + user.vote_town_code).to_i
    end
  end

end
