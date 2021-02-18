def assign_vote_circle_territories
  neighborhood_type = VoteCircleType.where("name like '_arri%'").pluck(:id).first
  town_type = VoteCircleType.where("name like '_unici%'").pluck(:id).first
  region_type = VoteCircleType.where("name like '_omarc%'").pluck(:id).first
  exterior_type = VoteCircleType.where("name like '_xter%'").pluck(:id).first
  spain_types = [["TB%",neighborhood_type],["TM%",town_type],["TC%",region_type]]
  spain_code ="ES"
  spain_types.each do |type,type_code|
    VoteCircle.all.where("code like ?",type).where(country_code:nil, autonomy_code: nil,province_code: nil).find_each do |vc|
      vc.vote_circle_type_id = type_code
      if vc.town.present?
        town_code = vc.town
        province_code = "p_#{vc.town[2,2]}"
        autonomy_code = Podemos::GeoExtra::AUTONOMIES[province_code][0]
        island = Podemos::GeoExtra::ISLANDS[vc.town]
        island_code = vc.island_code
        island_code = island.present? ? island[0] : nil unless island_code.present?
        country_code = spain_code
      else
        if vc.in_spain?
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

  exterior_circles = VoteCircle.all.where("code not like all(array[?])",spain_types).where(country_code:nil, autonomy_code: nil,province_code: nil)
  exterior_circles.find_each do |vc|
    vc.town = nil
    vc.province_code = nil
    vc.autonomy_code = nil
    vc.island_code = nil
    vc.country_code = vc.code[0,2].upcase
    vc.save!
  end
end

VoteCircleType.create([{name: "Barrial"}, {name: "Municipal"}, {name: "Comarcal"}, {name: "Exterior"}]) if VoteCircleType.all.count == 0

assign_vote_circle_territories
