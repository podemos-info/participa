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

    ip01 = "IP000000001"
    ip02 = "IP000000002"
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
    autonomies["c_#{UNKNOWN}"] = [UNKNOWN,[0]* num_columns].flatten
    progress.inc

    provinces = Hash[spain.map do |p| [ "p_%02d" % + p.index,["",p.name, [0]* num_columns ].flatten] end ]
    provinces["p_#{UNKNOWN}"] = [UNKNOWN, UNKNOWN, [0]* num_columns].flatten
    progress.inc

    #islands = Hash[ Podemos::GeoExtra::ISLANDS.map do |k, v| [ v[1], [0]* num_columns ] end ]
    progress.inc

    towns = Hash[ provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, ["","","",[0]* num_columns ].flatten] end
                  end.flatten(1) ]
    towns["m_#{UNKNOWN}"] = [UNKNOWN, UNKNOWN, UNKNOWN, [0]* num_columns].flatten
    towns_names = Hash[ *provinces_coded.map do |p|
                    spain.coded(p).subregions.map do |t| [ t.code, t.name] end
                  end.flatten ]
    progress.inc

    regions =  Hash[VoteCircle.where("code like 'TC%'").order(:region_area_id).pluck(:code,:name).map do |i,n| ["r_#{i}",["","",n,[0]* num_columns].flatten] end ]
    progress.inc

    circles_territory = Hash.new { |k, v| k[v] = 0 }

    circles = Hash[VoteCircle.all.order(:code).pluck(:code,:name).map do|i,n| [i,["","","",n,0]] end ]
    circles.each do |full_code,v|
      type_circle = full_code[0..1]
      ccaa = if autonomies.keys.include? "c_#{full_code[2..3]}" then "c_#{full_code[2..3]}" else "c_#{UNKNOWN}" end
      prov = if provinces.keys.include? "p_#{full_code[4..5]}" then "p_#{full_code[4..5]}" else "p_#{UNKNOWN}" end
      dc = calc_muni_dc("#{full_code[4..5]}#{full_code[6..8]}")
      town = if towns.keys.include? "m_#{full_code[4..5]}_#{full_code[6..8]}_#{dc}" then "m_#{full_code[4..5]}_#{full_code[6..8]}_#{dc}" else "m_#{UNKNOWN}" end
      count = full_code[9..-1]

      circles[full_code][0] = autonomies[ccaa][0] if ccaa != "c_00"
      circles[full_code][1] = provinces[prov][1] if  prov !="p_00"
      circles[full_code][2] = towns_names[town] unless full_code[6..8] == "000"

      circles_territory[type_circle] +=1
      circles_territory[ccaa] +=1
      circles_territory[prov] +=1
      circles_territory[town] +=1
      circles_territory["r_#{full_code}"] +=1 if type_circle == "TC"
    end
    progress.inc

    users.find_each do |u|

      if args.year
        u = u.version_at(date)
        next if !(u.present? && u.sms_confirmed_at.present? && u.not_banned? && u.vote_circle_id.present?.u.still_militant?)
      end

      empty_town="m_#{UNKNOWN}"
      full_code = u.vote_circle.code
      type_circle = full_code[0..1]
      dc = calc_muni_dc("#{full_code[4..5]}#{full_code[6..8]}")
      town = "m_#{full_code[4..5]}_#{full_code[6..8]}_#{dc}"
      ccaa = town == empty_town || [ip01,ip02].include?(full_code) ? u.autonomy_code : "c_#{full_code[2..3]}"
      ccaa = if autonomies.keys.include? ccaa then ccaa else "c_#{UNKNOWN}" end
      town = u.vote_town if town == empty_town || [ip01,ip02].include?(full_code)
      town = if towns.keys.include? town then town else "m_#{UNKNOWN}" end
      prov = town.empty? ? "p_#{UNKNOWN}" : "p_#{town[2..3]}"
      prov = if provinces.keys.include? prov then prov else "p_#{UNKNOWN}" end
      reg = "r_#{full_code}"

      #countries[if countries.include? u.country_name then u.country_name else UNKNOWN end][0] += 1 if u.country != SPAIN
      if is_exterior?(type_circle)
        countries[type_circle][1] +=1
        countries[type_circle][2] += 1 if full_code == ip01
        countries[type_circle][3] += 1 if full_code == ip02
      end

      circles[full_code][4] += 1

      autonomies[ccaa][1] += 1
      autonomies[ccaa][2] += 1 if full_code == ip01
      autonomies[ccaa][3] += 1 if full_code == ip02

      provinces[prov][2] += 1
      provinces[prov][3] += 1 if full_code == ip01
      provinces[prov][4] += 1 if full_code == ip02

      if type_circle =="TC"
        cod_prov_reg = "p_#{full_code[4..5]}"
        if provinces.keys.include? cod_prov_reg
          prov_reg = provinces[cod_prov_reg][1]
          ccaa_reg = Podemos::GeoExtra::AUTONOMIES[cod_prov_reg][1]
        elsif  provinces.keys.include? u.province.code
          cod_prov_reg = provinces[u.province.code][0]
          prov_reg = provinces[u.province.code][1]
          ccaa_reg = Podemos::GeoExtra::AUTONOMIES[u.province_code][1]
        else
          cod_prov_reg = UNKNOWN
          prov_reg = UNKNOWN
          ccaa_reg = UNKNOWN
        end
        provinces[cod_prov_reg][2] += 1
        regions[reg][0] = ccaa_reg
        regions[reg][1] = prov_reg
        regions[reg][3] +=1
      end

        towns[town][3] += 1
        towns[town][4] += 1 if full_code == ip01
        towns[town][5] += 1 if full_code == ip02
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

     regions.keys.each do |k|
       #   regions[k][4] = circles_territory[k]
       cod_prov_reg = "p_#{k[4..5]}"
       if provinces.keys.include? cod_prov_reg
         prov_reg = provinces[cod_prov_reg][1]
         ccaa_reg = Podemos::GeoExtra::AUTONOMIES[cod_prov_reg][1]
       else
         prov_reg = UNKNOWN
         ccaa_reg = UNKNOWN
       end
       regions[k][0] =  ccaa_reg if regions[k][0].blank?
       regions[k][1] =  prov_reg if regions[k][1].blank?
     end


    towns.keys.each do |k|
      if towns_names[k].present?
        prov = "p_#{k[2..3]}"
        towns[k][0] = Podemos::GeoExtra::AUTONOMIES[prov][1]
        towns[k][1] = provinces[prov][1]
        towns[k][2] =towns_names[k]
        towns[k][6] = circles_territory[k]
      end
    end

    folder = "tmp/census_militants"
    suffix = date.strftime
    headers = ["militantes", "militantes_circulo_construccion", "militantes_no_circulo", "n_circulos"]
    export_raw_data "militantes_exterior.#{suffix}", countries.sort, headers: ["País | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
    export_raw_data "militantes_ccaa.#{suffix}", autonomies.sort, headers: ["Comunidad autonoma | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
    export_raw_data "militantes_provincia.#{suffix}", provinces.sort, headers: ["Comunidad autonoma" ,"Provincia | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
    export_raw_data "militantes_comarca.#{suffix}", regions.sort, headers: ["Comunidad autonoma" ,"Provincia","Comarca | #{suffix}","militantes"], folder: folder do |k,d|
      d.flatten
    end
    progress.inc
    export_raw_data "militantes_municipio.#{suffix}", towns.sort, headers: ["Comunidad autonoma" ,"Provincia","Municipio | #{suffix}"] + headers, folder:folder do |d| d[1].flatten end
    progress.inc
    export_raw_data "militantes_circulo.#{suffix}", circles.sort, headers: ["Comunidad autonoma" ,"Provincia","Municipio", "Círculo | #{suffix}"] + headers, folder: folder do |k,d| d.flatten end
    progress.inc
  end
end