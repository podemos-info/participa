require 'csv'

namespace :podemos do

  desc "[podemos] Dump users emails with location information to create lists"
  task :dump_emails => :environment do
    FileUtils.mkdir_p("tmp/sendy") unless File.directory?("tmp/sendy")
    CSV.open( "tmp/sendy/users.csv", 'w', { force_quotes: true } ) do |writer|

      User.where.not(sms_confirmed_at: nil).where(country: "ES").pluck(:first_name, :last_name, :email, :province, :town).each do |user|
        province = user[3]
        town = user[4].downcase
        if not town.starts_with? "m_"
          prov = Carmen::Country.coded("ES").subregions.coded(province)
          if prov
            town = "m_%02d_"% (prov.index+1)
          else
            town = "m_"
          end
        end
        writer << [ user[0] + " " + user[1], user[2], town]
      end
      User.where.not(country: "ES", sms_confirmed_at: nil).pluck(:first_name, :last_name, :email).each do |user|
        writer << [ user[0] + " " + user[1], user[2], "e_" ]
      end

    end

  end

end
