require 'podemos_export'

UNKNOWN = "Desconocido"
FOREIGN = "Extranjeros"

namespace :podemos do

  desc "[podemos] Dump counters for users attributes"
  task :daily_census => :environment do
    total = User.confirmed.count
    progress = RakeProgressbar.new(total + 14)

    spain = Carmen::Country.coded("ES").subregions
    provinces_coded = spain.map do |r| r.code end
    progress.inc

    countries = Hash[ Carmen::Country.all.map do |c| [ c.name, 0 ] end ]
    countries[UNKNOWN] = 0
    progress.inc

    autonomies = Hash[ Podemos::GeoExtra::AUTONOMIES.map do |k, v| [ v[1], 0] end ]
    autonomies[FOREIGN] = 0
    progress.inc

    provinces = Hash[ spain.map do |p| [ p.name, 0 ] end ]
    provinces[UNKNOWN] = 0
    progress.inc

    islands = Hash[ Podemos::GeoExtra::ISLANDS.map do |k, v| [ v[1], 0] end ]
    progress.inc

    towns = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, 0 ] end
                  end.flatten ]
    towns[UNKNOWN] = 0
    towns_names = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, t.name] end
                  end.flatten ]
    towns_names[UNKNOWN] = UNKNOWN
    progress.inc

    postal_codes = Hash.new 0

    progress.inc

    User.confirmed.find_each do |u|
      countries[if countries.include? u.country_name then u.country_name else UNKNOWN end] += 1 

      if u.country=="ES"
        autonomies[u.autonomy_name] += 1 if not u.autonomy_name.empty?
        provinces[if provinces.include? u.province_name then u.province_name else UNKNOWN end] += 1
        towns[if towns.include? u.town then u.town else UNKNOWN end] += 1

        islands[u.island_name] += 1 if not u.island_name.empty?
        postal_codes[if u.postal_code =~ /^\d{5}$/ then u.postal_code else UNKNOWN end] += 1 
      else
        autonomies[FOREIGN] +=1
      end

      progress.inc
    end

    date = Date.today.strftime
    export_raw_data "countries.#{date}", countries.sort, [ "País", date ], "tmp/census" do |d| [ d[0], d[1] ] end
    progress.inc
    export_raw_data "autonomies.#{date}", autonomies.sort, [ "Comunidad autonoma", date ], "tmp/census" do |d| [ d[0], d[1] ] end
    progress.inc
    export_raw_data "provinces.#{date}", provinces.sort, [ "Provincia", date ], "tmp/census" do |d| [ d[0], d[1] ] end
    progress.inc
    export_raw_data "islands.#{date}", islands.sort, [ "Isla", date ], "tmp/census" do |d| [ d[0], d[1] ] end
    progress.inc
    export_raw_data "towns.#{date}", towns.sort, [ "Municipio", date ], "tmp/census" do |d| [ d[0], towns_names[d[0]], d[1] ] end
    progress.inc
    export_raw_data "postal_codes.#{date}", postal_codes.sort, [ "Código postal", date ], "tmp/census" do |d| [ d[0], d[1] ] end
    progress.finished
  end
end
