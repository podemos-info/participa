namespace :podemos do
  desc "[podemos] Generate SQL commands for lists creation in Sendy"
  task :generate_sendy_lists => :environment do
    sendy_lists = SendyListsUpdater.new Rails.application.secrets.sendy["appID"], Rails.application.secrets.sendy["userID"]

    sendy_lists.add_list "A - España", "m_"
    sendy_lists.add_list "A - Extranjero", "e_"

    # 50 provinces + 2 autonomous cities
    (01..52).each {|n| sendy_province "%02d" % n, sendy_lists}

    sendy_lists.close
  end

  desc "[podemos] Extract municipies information from INE"
  # http://www.ine.es/jaxi/menu.do?type=pcaxis&path=/t20/e245/codmun&file=inebase 
  #    Relación de municipios y códigos por provincias a 01-01-2014
  #    http://www.ine.es/daco/daco42/codmun/codmunmapa.htm
  #
  # Extract municipies for a given province in the Carmen format,
  # * db/iso_data/base/world/es/#{prefix}.yml
  # * config/locales/carmen/es/#{prefix}.yml
  # where prefix is Carmen internal code, eg: "vi" for Alava
  #
  task :municipies_extract => :environment do
    # 50 provinces + 2 autonomous cities
    (01..52).each {|n| carmen_province "%02d" % n}
  end

  def get_prefix_province prefix
  # http://www.ine.es/jaxi/menu.do?type=pcaxis&path=/t20/e245/codmun&file=inebase 
  #    Relación de provincias con sus códigos
  #    http://www.ine.es/daco/daco42/codmun/cod_provincia.htm 
  #
    case prefix
      when "01" then "VI"
      when "02" then "AB"
      when "03" then "A"
      when "04" then "AL"
      when "05" then "AV"
      when "06" then "BA"
      when "07" then "IB"
      when "08" then "B"
      when "09" then "BU"
      when "10" then "CC"
      when "11" then "CA"
      when "12" then "CS"
      when "13" then "CR"
      when "14" then "CO"
      when "15" then "C"
      when "16" then "CU"
      when "17" then "GI"
      when "18" then "GR"
      when "19" then "GU"
      when "20" then "SS"
      when "21" then "H"
      when "22" then "HU"
      when "23" then "J"
      when "24" then "LE"
      when "25" then "L"
      when "26" then "LO"
      when "27" then "LU"
      when "28" then "M"
      when "29" then "MA"
      when "30" then "MU"
      when "31" then "NA"
      when "32" then "OR"
      when "33" then "O"
      when "34" then "P"
      when "35" then "GC"
      when "36" then "PO"
      when "37" then "SA"
      when "38" then "TF"
      when "39" then "S"
      when "40" then "SG"
      when "41" then "SE"
      when "42" then "SO"
      when "43" then "T"
      when "44" then "TE"
      when "45" then "TO"
      when "46" then "V"
      when "47" then "VA"
      when "48" then "BI"
      when "49" then "Z"
      when "50" then "ZA"
      when "51" then "CE"
      when "52" then "ML"
    end
  end

  def sendy_province number_province, sendy_lists
    # Given a number (first column) like 01 or 52 parse the CSV file and 
    # extract all the municipalities for that province. 
    
    # Extract all municipies on a list like 
    # [ ["m_01_001_4", "Alegría-Dulantzi"], ["m_01_002_9", "Amurrio"] ... ]
    municipies = []
    raw = CSV.read("db/ine/14codmun.csv")
    raw.each do |a|
      if a[0] == number_province
        municipies << [ "m_#{a[0]}_#{a[1]}_#{a[2]}" , a[3] ]
      end
    end
    prefix = get_prefix_province number_province.to_s

    province_name = Carmen::Country.coded("ES").subregions.coded(prefix).name
    sendy_lists.add_list "B - #{province_name}", "m_#{number_province}"

    municipies.each do |mun|
      c = mun[0]
      sendy_lists.add_list "C - #{province_name} - #{mun[1]}", "#{c.downcase}"
    end
  end

  def carmen_province number_province
    # Given a number (first column) like 01 or 52 parse the CSV file and 
    # extract all the municipalities for that province. 
    
    # Extract all municipies on a list like 
    # [ ["m_01_001_4", "Alegría-Dulantzi"], ["m_01_002_9", "Amurrio"] ... ]
    municipies = []
    raw = CSV.read("db/ine/14codmun.csv")
    raw.each do |a|
      if a[0] == number_province
        municipies << [ "m_#{a[0]}_#{a[1]}_#{a[2]}" , a[3] ]
      end
    end
    prefix = get_prefix_province number_province.to_s

    # Dump them on Carmen format
    carmen_db_iso_file = "db/iso_data/base/world/es/#{prefix.downcase}.yml"
    File.delete(carmen_db_iso_file) if File.exist?(carmen_db_iso_file)
    data_file = File.open(carmen_db_iso_file, 'a')
    data_file.puts "---"

    carmen_i18n_file = "config/locales/carmen/es/#{prefix.downcase}.yml"
    File.delete(carmen_i18n_file) if File.exist?(carmen_i18n_file)
    i18n_file = File.open(carmen_i18n_file, 'a')
    i18n_file.puts "---
es:
  world:
    es:
      #{prefix.downcase}:
"
    municipies.each do |mun|
      c = mun[0]
      data_file.puts "- code: #{c.downcase}
  type: municipality"
      i18n_file.puts "        #{c.downcase}:
          name: \"#{mun[1]}\""
    end
    data_file.close
    i18n_file.close
  end

  class SendyListsUpdater
    def initialize(appID, userID)
      @appID = appID
      @userID = userID

      FileUtils.mkdir_p("tmp/sendy") unless File.directory?("tmp/sendy")
      @sendy_lists_file = File.open("tmp/sendy/update_lists.sql", 'w')

      @INSERT_TEMPLATE = ERB.new <<-END
INSERT INTO lists (app, userID, name, thankyou_message, goodbye_message, confirmation_email, custom_fields)
SELECT <%= @appID %>, <%= @userID %>, "<%= name %> - <%= code %>", <%= @EMPTY_PAGE %>, <%= @EMPTY_PAGE %>, <%= @EMPTY_PAGE %>, NULL
FROM lists WHERE NOT EXISTS(
  SELECT * FROM lists l WHERE l.name LIKE '% - <%= code %>'
) LIMIT 1;

      END
      @EMPTY_PAGE = "'<html><head></head><body></body></html>'"
    end

    def add_list name, code
      @sendy_lists_file.puts @INSERT_TEMPLATE.result(binding)
    end

    def close
      @sendy_lists_file.puts("SELECT id FROM lists WHERE app = #{@appID} and userID = #{@userID};")
      @sendy_lists_file.close
    end
  end
end