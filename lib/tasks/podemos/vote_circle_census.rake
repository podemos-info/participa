require 'podemos_export'

#UNKNOWN = "Desconocido"
#FOREIGN = "Extranjeros"
#NATIVE  = "Españoles"
SPAIN   = "ES"
namespace :podemos do
  def calc_muni_dc (m)
    w = [[0,1,2,3,4,5,6,7,8,9],[0,3,8,2,7,4,1,5,9,6],[0,2,4,6,8,1,3,5,7,9]]
    c = m.to_s.rjust(5,'0').split('').map(&:to_i)
    dc = (10-(0..4).map {|d| w[2 - d % 3][c[d]]}.reduce(:+)) % 10
  end

  def get_militants_not_flagged
    ids = User.verified.not_militant.where.not(vote_circle:nil).pluck(:id)
    ids2=[]
    User.where(id:ids).each do |u|
      ids2.push(u.id) if u.still_militant?
    end
    ids2
  end

  def update_militants_not_flagged
    ids2 = get_militants_not_flagged
    User.where(id:ids2).each do |u|
      status = u.still_militant?
      u.militant = status
      u.update_columns(flags:u.flags)
    end
    puts("actualizado el flag de militancia en #{ids2.count} registros")
  end

  def is_exterior?(type_circle)
    type_circle != "IP" && type_circle != "TB" && type_circle != "TC" && type_circle != "TM"
  end

  desc "[podemos] Dump counters for users attributes"
  task :vote_circle_census, [:year,:month,:day] => :environment do |t, args|
    args.with_defaults(:year => nil, :month=>nil, :day=>nil)

    update_militants_not_flagged

    if args.year.nil?
        users = User.militant
        date = Date.today        
    else
        users = User.militant.with_deleted
        date = Date.civil args.year.to_i, args.month.to_i, args.day.to_i
    end
    
    num_columns = 4

    total = users.count

    progress = RakeProgressbar.new(total + 15)

    spain = Carmen::Country.coded(SPAIN).subregions
    provinces_coded = spain.map do |r| r.code end
    progress.inc

    countries = Hash[Carmen::Country.all.select{|c| c.code !="ES" && c.code !="TC" && c.code != "TM"}.map do |c| [c.code, [c.name, [0] * 4].flatten] end]
    countries[UNKNOWN] =[ UNKNOWN, [0]* num_columns].flatten
    progress.inc

    autonomies = Hash[ Podemos::GeoExtra::AUTONOMIES.map do |k, v| [ v[0],[v[1], [0]* num_columns].flatten] end ]
    #autonomies[FOREIGN] = [0]* num_columns
    autonomies[UNKNOWN] = [UNKNOWN,[0]* num_columns].flatten
    autonomies_hash = Podemos::GeoExtra::AUTONOMIES
    progress.inc

    provinces = Hash[ spain.map do |p| [ "p_%02d" % + p.index,["",p.name, [0]* num_columns ].flatten] end ]
    provinces[UNKNOWN] = [UNKNOWN, UNKNOWN, [0]* num_columns].flatten
    progress.inc

    #islands = Hash[ Podemos::GeoExtra::ISLANDS.map do |k, v| [ v[1], [0]* num_columns ] end ]
    progress.inc

    towns = Hash[ provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, ["","","",[0]* num_columns ].flatten] end
                  end.flatten(1) ]
    towns[UNKNOWN] = [UNKNOWN, UNKNOWN, UNKNOWN, [0]* num_columns].flatten
    towns_names = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, t.name] end
                  end.flatten ]
    progress.inc

    regions =  Hash[VoteCircle.where.not(region_area_id:nil).order(:region_area_id).pluck(:region_area_id,:name).map do |i,n| ["r_#{i.to_s.rjust(2,"0") }",["","",n,[0]* num_columns].flatten] end ]
    progress.inc

    circles_territory = Hash.new { |k, v| k[v] = 0 }

    circles = Hash[VoteCircle.all.order(:code).pluck(:code,:name).map do|i,n| [i,["","","",n,0]] end ]
    circles.each do |full_code,v|
      empty_town="m_00_000_0"
      type_circle = full_code[0..1]
      ccaa = "c_#{full_code[2..3]}"
      prov = "p_#{full_code[4..5]}"
      dc = calc_muni_dc("#{full_code[4..5]}#{full_code[6..8]}")
      town = "m_#{full_code[4..5]}_#{full_code[6..8]}_#{dc}"
      count = full_code[9..-1]

      circles[full_code][0] = autonomies[ccaa][0] if ccaa != "c_00"
      circles[full_code][1] = provinces[prov][1] if  prov !="p_00"
      circles[full_code][2] = towns_names[town] unless full_code[6..8] == "000"

      circles_territory[type_circle] +=1
      circles_territory[ccaa] +=1 if ccaa != "c_00"
      circles_territory[prov] +=1 if prov != "p_00"
      circles_territory[town] +=1 if town != empty_town
      circles_territory[count] +=1 if type_circle == "TC"
    end
    progress.inc

    users.find_each do |u|

      if args.year
        u = u.version_at(date)
        next if !(u.present? && u.sms_confirmed_at.present? && u.not_banned? && u.vote_circle_id.present?.u.still_militant?)
      end

      empty_town="m_00_000_0"
      full_code = u.vote_circle.code
      type_circle = full_code[0..1]
      dc = calc_muni_dc("#{full_code[4..5]}#{full_code[6..8]}")
      town = "m_#{full_code[4..5]}_#{full_code[6..8]}_#{dc}"
      ccaa = town == empty_town ? u.autonomy_code : "c_#{full_code[2..3]}"
      ccaa = UNKNOWN if ccaa.empty?
      town = u.vote_town if town == empty_town
      town = UNKNOWN if town.empty?
      prov = town.empty? ? UNKNOWN : "p_#{town[2..3]}"
      count = full_code[9..-1]
      reg ="r_#{count}"

      #countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][0] += 1 if u.country != SPAIN
      if is_exterior?(type_circle)
        countries[type_circle][1] +=1
        countries[type_circle][2] += 1 if full_code =="IP000000001"
        countries[type_circle][3] += 1 if full_code =="IP000000002"
      end

      circles[full_code][4] += 1
      if autonomies[ccaa].present?
        autonomies[ccaa][1] += 1 if ccaa != "c_00"
        autonomies[ccaa][2] += 1 if ccaa != "c_00" && full_code =="IP000000001"
        autonomies[ccaa][3] += 1 if ccaa != "c_00" && full_code =="IP000000002"
      end

      provinces[prov][2] += 1 if prov != "p_00"
      provinces[prov][3] += 1 if prov != "p_00" && full_code =="IP000000001"
      provinces[prov][4] += 1 if prov != "p_00" && full_code =="IP000000002"

      if type_circle =="TC"
        regions[reg][0] = Podemos::GeoExtra::AUTONOMIES[u.province_code][1]
        regions[reg][1] = provinces[u.province_code][0]
        regions[reg][3] +=1
      end

      if towns[town].present?
        towns[town][3] += 1 if town != empty_town
        towns[town][4] += 1 if town != empty_town && full_code =="IP000000001"
        towns[town][5] += 1 if town != empty_town && full_code =="IP000000002"
      end
    end
    progress.inc

    # set count of circles and missing territory names per territory
    countries.keys.each do |k|
      countries[k][4] = circles_territory[k] if is_exterior?(k)
    end

    autonomies.keys.each do |k|
      autonomies[k][4] = circles_territory[k]
    end

    provinces.keys.each do |k|
      if Podemos::GeoExtra::AUTONOMIES[k].present?
        provinces[k][0] = Podemos::GeoExtra::AUTONOMIES[k][1]
        provinces[k][5] = circles_territory[k]
      end
    end

    # regions.keys.each do |k|
    #   regions[k][4] = circles_territory[k]
    # end

    towns.keys.each do |k|
      if towns_names[k].present?
        prov = "p_#{k[2..3]}"
        towns[k][0] = Podemos::GeoExtra::AUTONOMIES[prov][1]
        towns[k][1] = provinces[prov][0]
        towns[k][2] =towns_names[k]
        towns[k][6] = circles_territory[k]
      end
    end

    folder = "tmp/census_militants"
    suffix = date.strftime
    headers = ["militantes", "militantes_circulo_construccion", "militantes_no_circulo", "n_circulos"]
    export_raw_data "militantes_exterior.#{suffix}", countries.sort, headers: ["País | #{suffix}"] + headers, folder: folder do |d| d.flatten end
    progress.inc
    export_raw_data "militantes_ccaa.#{suffix}", autonomies.sort, headers: ["Comunidad autonoma | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
    export_raw_data "militantes_provincia.#{suffix}", provinces.sort, headers: ["Comunidad autonoma" ,"Provincia | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
    export_raw_data "militantes_comarca.#{suffix}", regions.sort, headers: ["Comunidad autonoma" ,"Provincia","Comarca | #{suffix}","militantes"], folder: folder do |k,d|
      d.flatten
    end
    progress.inc
    export_raw_data "militantes_municipio.#{suffix}", towns.sort, headers: ["Comunidad autonoma" ,"Provincia","Municipio | #{suffix}"] + headers, folder:folder do |d| [ d[0], towns_names[d[0]] ] + d[1].flatten end
    progress.inc
    export_raw_data "militantes_circulo.#{suffix}", circles.sort, headers: ["Comunidad autonoma" ,"Provincia","Municipio", "Círculo | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
  end
end