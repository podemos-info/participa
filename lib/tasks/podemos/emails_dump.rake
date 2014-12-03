require 'csv'

namespace :podemos do

  desc "[podemos] Dump users emails with location information to create lists"
  task :dump_emails => :environment do
    FileUtils.mkdir_p("tmp/sendy") unless File.directory?("tmp/sendy")
    CSV.open( "tmp/sendy/users.csv", 'w' ) do |writer|

      User.where.not(sms_confirmed_at: nil).where(country: "ES").pluck(:first_name, :last_name, :email, :town).each do |user|
        writer << [ user[0] + " " + user[1], user[2], user[3] ]
      end
      User.where.not(country: "ES", sms_confirmed_at: nil).pluck(:first_name, :last_name, :email).each do |user|
        writer << [ user[0] + " " + user[1], user[2], "e_" ]
      end

    end

  end

end
