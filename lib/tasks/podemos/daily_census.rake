require 'podemos_export'

UNKNOWN = "Desconocido"
FOREIGN = "Extranjeros"

namespace :podemos do

    
  desc "[podemos] Dump counters for users attributes"
  task :daily_census, [:year,:month,:day] => :environment do |t, args|
    args.with_defaults(:year => nil, :month=>nil, :day=>nil)

    if args.year.nil?
        users = User.confirmed
        date = Date.today        
    else
        users = User.with_deleted
        date = Date.civil args.year.to_i, args.month.to_i, args.day.to_i
    end
    
    active_date = date - eval(Rails.application.secrets.users["active_census_range"])

    total = users.count

    progress = RakeProgressbar.new(total + 14)

    spain = Carmen::Country.coded("ES").subregions
    provinces_coded = spain.map do |r| r.code end
    progress.inc

    countries = Hash[ Carmen::Country.all.map do |c| [ c.name, [0]*4 ] end ]
    countries[UNKNOWN] = [0]*4
    progress.inc

    autonomies = Hash[ Podemos::GeoExtra::AUTONOMIES.map do |k, v| [ v[1], [0]*4] end ]
    autonomies[FOREIGN] = [0]*4
    progress.inc

    provinces = Hash[ spain.map do |p| [ p.name, [0]*4 ] end ]
    provinces[UNKNOWN] = [0]*4
    progress.inc

    islands = Hash[ Podemos::GeoExtra::ISLANDS.map do |k, v| [ v[1], [0]*4 ] end ]
    progress.inc

    towns = Hash[ provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, [0]*4 ] end
                  end.flatten(1) ]
    towns[UNKNOWN] = [0]*4
    towns_names = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, t.name] end
                  end.flatten ]
    towns_names[UNKNOWN] = UNKNOWN
    progress.inc

    postal_codes = Hash.new [0]*4

    progress.inc

    users.find_each do |u|

      if args.year
        u = u.version_at(date)
        next if u.nil?
      end
     
      countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][0] += 1 
      if u.country=="ES"
        autonomies[u.autonomy_name][0] += 1 if not u.autonomy_name.empty?
        provinces[if provinces.include? u.province_name then u.province_name else UNKNOWN end][0] += 1
        towns[if towns.include? u.town then u.town else UNKNOWN end][0] += 1
        islands[u.island_name][0] += 1 if not u.island_name.empty?
        postal_codes[if u.postal_code =~ /^\d{5}$/ then u.postal_code else UNKNOWN end][0] += 1 
      else
        autonomies[FOREIGN][0] +=1
      end

      if u.current_sign_in_at > active_date then
        countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][1] += 1 
        if u.country=="ES"
          autonomies[u.autonomy_name][1] += 1 if not u.autonomy_name.empty?
          provinces[if provinces.include? u.province_name then u.province_name else UNKNOWN end][1] += 1
          towns[if towns.include? u.town then u.town else UNKNOWN end][1] += 1
          islands[u.island_name][1] += 1 if not u.island_name.empty?
          postal_codes[if u.postal_code =~ /^\d{5}$/ then u.postal_code else UNKNOWN end][1] += 1 
        else
          autonomies[FOREIGN][1] +=1
        end
      end

      if u.vote_town
        autonomies[u.vote_autonomy_name][2] += 1 if not u.vote_autonomy_name.empty?
        provinces[if provinces.include? u.vote_province_name then u.vote_province_name else UNKNOWN end][2] += 1
        towns[if towns.include? u.vote_town then u.vote_town else UNKNOWN end][2] += 1
        islands[u.vote_island_name][2] += 1 if not u.island_name.empty?

        if u.current_sign_in_at > active_date then
          autonomies[u.vote_autonomy_name][3] += 1 if not u.vote_autonomy_name.empty?
          provinces[if provinces.include? u.vote_province_name then u.vote_province_name else UNKNOWN end][3] += 1
          towns[if towns.include? u.vote_town then u.vote_town else UNKNOWN end][3] += 1
          islands[u.vote_island_name][3] += 1 if not u.island_name.empty?
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
    progress.finished
  end
end
