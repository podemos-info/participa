require_dependency Rails.root.join('app', 'models', 'election').to_s

class Election

  SCOPE << ["Distritos", 6]

  def full_title_for user
    if multiple_territories?
      suffix =  case self.scope
                  when 1 then " en #{user.vote_autonomy_name}"
                  when 2 then " en #{user.vote_province_name}"
                  when 3 then " en #{user.vote_town_name}"
                  when 4 then " en #{user.vote_island_name}"
                  when 6 then " en #{user.vote_district_name}"
                end
      if not has_valid_location_for? user
        suffix = " (no hay votación#{suffix})"
      end
    end
    #"#{self.title}#{suffix}"
    "#{self.title}"
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
      when 6 then user.has_vote_town? and self.election_locations.any? {|l| l.location == user.vote_district_numeric}
    end
  end

  def has_valid_user_created_at? user
    self.user_created_at_max.nil? or self.user_created_at_max > user.created_at
  end

  def current_total_census
    case self.scope
      when 0 then User.confirmed.not_banned.count
      when 1 then User.confirmed.not_banned.ransack( {vote_autonomy_in: self.election_locations.map {|l| "c_#{l.location}" }}).result.count
      when 2 then User.confirmed.not_banned.ransack( {vote_province_in: self.election_locations.map {|l| "p_#{l.location}" }}).result.count
      when 3 then User.confirmed.not_banned.where(vote_town: self.election_locations.map {|l| "m_#{l.location[0..1]}_#{l.location[2..4]}_#{l.location[5]}" }).count
      when 4 then User.confirmed.not_banned.ransack( {vote_island_in: self.election_locations.map {|l| "i_#{l.location}" }}).result.count
      when 5 then User.confirmed.not_banned.where.not(country:"ES").count
      when 6 then 
      when 6 then User.confirmed.not_banned.where(district: self.election_locations.map {|l| "d_#{l.location}" }).count
    end
  end

  def multiple_territories?
    [1,2,3,4,6].member? self.scope
  end

  def scoped_agora_election_id user
    user_location = case self.scope
      when 1
        user.vote_autonomy_numeric
      when 2
        user.vote_province_numeric
      when 3
        user.vote_town_numeric
      when 4
        user.vote_island_numeric
      when 6
        user.vote_district_numeric
      else
        "00"
    end
    Rails.logger.info "user_location: #{user_location}"
    election_location = self.election_locations.find_by_location user_location
    "#{self.agora_election_id}#{election_location.override or election_location.location}#{election_location.agora_version}".to_i
  end

end
