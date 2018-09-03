require 'podemos_export'

UNKNOWN = "Desconocido"
FOREIGN = "Extranjeros"
NATIVE = "Españoles"

namespace :podemos do
  desc "[podemos] Dump counters for users attributes"
  task :daily_census, [:year,:month,:day] => :environment do |t, args|
    args.with_defaults(:year => nil, :month=>nil, :day=>nil)

    if args.year.nil?
        users = User.confirmed.not_banned
        date = Date.today        
    else
        users = User.with_deleted
        date = Date.civil args.year.to_i, args.month.to_i, args.day.to_i
    end
    
    num_columns = 5
    active_date = date - eval(Rails.application.secrets.users["active_census_range"])

    total = users.count

    progress = RakeProgressbar.new(total + 15)

    spain = Carmen::Country.coded("ES").subregions
    provinces_coded = spain.map do |r| r.code end
    progress.inc

    countries = Hash[ Carmen::Country.all.map do |c| [ c.name, [0]* num_columns ] end ]
    countries[UNKNOWN] = [0]* num_columns
    progress.inc

    autonomies = Hash[ Podemos::GeoExtra::AUTONOMIES.map do |k, v| [ v[1], [0]* num_columns] end ]
    autonomies[FOREIGN] = [0]* num_columns
    progress.inc

    provinces = Hash[ spain.map do |p| [ p.name, [0]* num_columns ] end ]
    provinces[UNKNOWN] = [0]* num_columns
    progress.inc

    islands = Hash[ Podemos::GeoExtra::ISLANDS.map do |k, v| [ v[1], [0]* num_columns ] end ]
    progress.inc

    towns = Hash[ provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, [0]* num_columns ] end
                  end.flatten(1) ]
    towns[UNKNOWN] = [0]* num_columns
    towns_names = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, t.name] end
                  end.flatten ]
    towns_names[UNKNOWN] = UNKNOWN
    progress.inc

    postal_codes = Hash.new [0]* num_columns

    users_verified = Hash.new
    users_verified[NATIVE] = [0]* num_columns
    users_verified[FOREIGN] = [0]* num_columns

    progress.inc

    users.find_each do |u|

      if args.year
        u = u.version_at(date)
        next if !(u.present? && u.sms_confirmed_at.present? && u.not_banned?)
      end
     
      countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][0] += 1 
      if u.country=="ES"
        autonomies[u.autonomy_name][0] += 1 if not u.autonomy_name.empty?
        provinces[if provinces.include? u.province_name then u.province_name else UNKNOWN end][0] += 1
        towns[if towns.include? u.town then u.town else UNKNOWN end][0] += 1
        islands[u.island_name][0] += 1 if not u.island_name.empty?
        postal_codes[if u.postal_code =~ /^\d{5}$/ then u.postal_code else UNKNOWN end][0] += 1
        users_verified[NATIVE][0] += 1 if u.verified?
      else
        autonomies[FOREIGN][0] +=1
        users_verified[FOREIGN][0] += 1 if u.verified?
      end

      if u.current_sign_in_at.present? && u.current_sign_in_at > active_date then
        countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][1] += 1 
        if u.country=="ES"
          autonomies[u.autonomy_name][1] += 1 if not u.autonomy_name.empty?
          provinces[if provinces.include? u.province_name then u.province_name else UNKNOWN end][1] += 1
          towns[if towns.include? u.town then u.town else UNKNOWN end][1] += 1
          islands[u.island_name][1] += 1 if not u.island_name.empty?
          postal_codes[if u.postal_code =~ /^\d{5}$/ then u.postal_code else UNKNOWN end][1] += 1
          users_verified[NATIVE][1] += 1 if u.verified?
        else
          autonomies[FOREIGN][1] +=1
          users_verified[FOREIGN][1] += 1 if u.verified?
        end
      end

      if u.vote_town
        autonomies[u.vote_autonomy_name][2] += 1 if not u.vote_autonomy_name.empty?
        provinces[if provinces.include? u.vote_province_name then u.vote_province_name else UNKNOWN end][2] += 1
        towns[if towns.include? u.vote_town then u.vote_town else UNKNOWN end][2] += 1
        islands[u.vote_island_name][2] += 1 if not u.vote_island_name.empty?
        users_verified[NATIVE][2] += 1 if u.verified?

        if u.current_sign_in_at.present? && u.current_sign_in_at > active_date then
          autonomies[u.vote_autonomy_name][3] += 1 if not u.vote_autonomy_name.empty?
          provinces[if provinces.include? u.vote_province_name then u.vote_province_name else UNKNOWN end][3] += 1
          towns[if towns.include? u.vote_town then u.vote_town else UNKNOWN end][3] += 1
          islands[u.vote_island_name][3] += 1 if not u.vote_island_name.empty?
          users_verified[NATIVE][3] += 1 if u.verified?
        end      
      end

      if u.verified?
        if u.country=="ES"
          autonomies[u.vote_autonomy_name][4] += 1 if not u.vote_autonomy_name.empty?
          provinces[if provinces.include? u.vote_province_name then u.vote_province_name else UNKNOWN end][4] += 1
          towns[if towns.include? u.vote_town then u.vote_town else UNKNOWN end][4] += 1
          islands[u.vote_island_name][4] += 1 if not u.vote_island_name.empty?
          users_verified[NATIVE][4] += 1 if u.verified?
        else
          autonomies[FOREIGN][4] +=1
          users_verified[FOREIGN][4] += 1 if u.verified?
        end
      end

      progress.inc
    end

 
    suffix = date.strftime
    export_raw_data "countries.#{suffix}", countries.sort, headers: [ "País", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.inc
    export_raw_data "autonomies.#{suffix}", autonomies.sort, headers: [ "Comunidad autonoma", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.inc
    export_raw_data "provinces.#{suffix}", provinces.sort, headers: [ "Provincia", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.inc
    export_raw_data "islands.#{suffix}", islands.sort, headers: [ "Isla", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.inc
    export_raw_data "towns.#{suffix}", towns.sort, headers: [ "Municipio", suffix ], folder:"tmp/census" do |d| [ d[0], towns_names[d[0]] ] + d[1].flatten end
    progress.inc
    export_raw_data "postal_codes.#{suffix}", postal_codes.sort, headers: [ "Código postal", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.inc
    export_raw_data "users_verified.#{suffix}", users_verified.sort, headers: [ "Usuarios verificados", suffix ], folder: "tmp/census" do |d| d.flatten end
    progress.finished
  end
end
