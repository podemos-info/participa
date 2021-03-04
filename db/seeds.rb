def assign_vote_circle_territories
  internal_type = 0
  neighborhood_type = 1
  town_type = 2
  region_type = 3
  exterior_type = 4

  spain_types = [["TB%",neighborhood_type],["TM%",town_type],["TC%",region_type]]
  internal = ["IP%", internal_type]
  known_types  = ["TB%", "TM%", "TC%", "IP%"]
  spain_code ="ES"

  internal_circles = VoteCircle.all.where("code like ?",internal[0]).where(country_code:nil, autonomy_code: nil,province_code: nil)
  internal_circles.find_each do |vc|
    vc.kind = internal[1]
    vc.town = nil
    vc.province_code = nil
    vc.autonomy_code = nil
    vc.island_code = nil
    vc.country_code = nil
    vc.save!
  end

  spain_types.each do |type,type_code|
    VoteCircle.all.where("code like ?",type).where(country_code:nil, autonomy_code: nil,province_code: nil).find_each do |vc|
      vc.kind = type_code
      if vc.town.present?
        town_code = vc.town
        province_code = "p_#{vc.town[2,2]}"
        autonomy_code = Podemos::GeoExtra::AUTONOMIES[province_code][0]
        island = Podemos::GeoExtra::ISLANDS[vc.town]
        island_code = vc.island_code
        island_code = island.present? ? island[0] : nil unless island_code.present?
        country_code = spain_code
      else
        if vc.code_in_spain?
          town_code = nil
          autonomy_code = "c_#{vc.code[2,2]}"
          province_code = "p_#{vc.code[4,2]}"
          island_code = vc.island_code
          country_code = spain_code
        else
          town_code = nil
          province_code = nil
          autonomy_code = nil
          island_code = nil
          country_code = vc.code[0,2].upcase
        end
      end
      vc.town = town_code
      vc.province_code = province_code
      vc.autonomy_code = autonomy_code
      vc.island_code = island_code
      vc.country_code = country_code
      vc.save!
    end
  end

  exterior_circles = VoteCircle.all.where("code not like all(array[?])",known_types).where(country_code:nil, autonomy_code: nil,province_code: nil)
  exterior_circles.find_each do |vc|
    vc.kind = exterior_type
    vc.town = nil
    vc.province_code = nil
    vc.autonomy_code = nil
    vc.island_code = nil
    vc.country_code = vc.code[0,2].upcase
    vc.save!
  end
end

assign_vote_circle_territories

 Order.where("payed_at > ?",Date.parse("2020-09-30")).where(target_territory:nil).find_each do |order|
   order.target_territory = order.generate_target_territory
   order.save!
 end
