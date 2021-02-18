namespace :podemos do

  desc "[podemos] Assign vote_circle territories to orders from a specific month and year"
  task :add_vote_circle_territories_to_orders, [:month, :year] => :environment do |t, args|
    args.with_defaults(:month => Date.today.month, :year => Date.today.year)
    min_date =Date.civil(args.year.to_i,args.month.to_i,1)
    max_date =Date.today
    os = Order.where("created_at between ? and ?",min_date,max_date).order(created_at:"ASC")
    os.each do |o|
      next unless o.user_id
      u = User.with_deleted.find(o.user_id)
      u.version_at(o.created_at)
      if u.vote_circle_id.present?
        circle = u.vote_circle
        if circle.town.present?
          town_code = circle.town
          autonomy_code = circle.autonomy_code
          island = Podemos::GeoExtra::ISLANDS[circle.town]
          island_code = circle.island_code
          island_code = island.present? ? island[0] : o.island_code unless island_code.present?
        else
          if circle.in_spain?
            town_code = o.town_code
            autonomy_code = circle.autonomy_code
            island_code = circle.island_code
            island_code = o.island_code unless island_code.present?
          else
            town_code = o.town_code
            autonomy_code = o.autonomy_code
            island_code = o.island_code
          end
        end
      else
        town_code = o.town_code
        autonomy_code = o.autonomy_code
        island_code = o.island_code
      end
      o.vote_circle_town_code = town_code if o.town_code.present?
      o.vote_circle_autonomy_code = autonomy_code if o.autonomy_code.present?
      o.vote_circle_island_code = island_code if o.island_code.present?
      o.save!
    end
  end
end