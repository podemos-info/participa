require 'csv'

namespace :podemos do

  desc "[podemos] Dump users emails with location information to create lists"
  task :dump_emails => :environment do
    FileUtils.mkdir_p("tmp/sendy") unless File.directory?("tmp/sendy")
    CSV.open( "tmp/sendy/users.csv", 'w', { force_quotes: true } ) do |writer|

      User.confirmed.find_each do |user|
        row = [ user.full_name, user.email ]
        town = user.vote_town
        prov = user.vote_province_code
        district = user.vote_district
        if town
          row << town
          row << "#{town.sub("m","d")}_#{district}" if district
        elsif prov
          prov[0] = "m"
          row << prov + "_"
        else
          row << "m_"
        end

        row << "e_" if user.country!="ES"

        if user.urban_vote_town?
          row << "t_urban"
        elsif user.semi_urban_vote_town?
          row << "t_semi_urban"
        else
          row << "t_rural"
        end

        if user.militant?
          code = user.vote_circle.code
          if code[0, 2] == "IP"
            row << "mc_"
          elsif code[0] != "T"
            row << "mce_"
          elsif code[6, 3].to_i == 0
            row << "mc_#{code[4, 2]}_"
          else
            row << "mc_#{code[4, 2]}_#{code[6, 3]}_#{code[9, 2]}"
          end   
        end

        writer << row
      end
    end

  end

end
