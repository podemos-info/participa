class PodemosImport
  # Importa los contenidos desde un CSV a la aplicación
  # La contraseña es el token enviado por SMS
  #
  # $ rails console staging
  # > require 'podemos_import'
  # > PodemosImport.init('/home/capistrano/juntos.csv')
  #
  # $ bundle exec rake environment resque:work QUEUE=* RAILS_ENV=staging 
  #
  #

  def self.convert_document_type(doc_type, doc_number)
    # doctypes: 
    # DNI = 1
    # NIE = 2
    # Pasaporte = 3
    ( doc_type == "Pasaporte" ) ? 3 : ( doc_number.starts_with?("Z", "X", "Y") ? 2 : 1 )
  end

  def self.convert_country(country)
    # normalizamos paises usando Carmen 
    I18n.locale = :ca # locale sin traducciones para que nos devuelva lo de :en
    country_c = Carmen::Country.named(country)
    if country_c.nil? 
      I18n.locale = :es
      country_c = Carmen::Country.named(country)
      if country_c.nil? 
        return country
      else 
        return country_c.code
      end
    else 
      return country_c.code
    end
  end

  def self.convert_province(postal_code, country, province)
    # intentamos  convertir por postal_code, si es de españa y el CP corresponde con alguno devolvemos la provincia.
    # si no encuentra la provincia basada en el postal_code + country, devuelve la provincia que ya esta puesta
    # normalizamos provincias
    all_pcs = {"01"=>"vi", "02"=>"ab", "03"=>"a", "04"=>"al", "05"=>"av", "06"=>"ba", "07"=>"bi", "08"=>"b", "09"=>"bu", "10"=>"cc", "11"=>"ca", "12"=>"cs", "13"=>"cr", "14"=>"co", "15"=>"c", "16"=>"cu", "17"=>"gi", "18"=>"gr", "19"=>"gu", "20"=>"ss", "21"=>"h", "22"=>"hu", "23"=>"j", "24"=>"le", "25"=>"l", "26"=>"lo", "27"=>"lu", "28"=>"m", "29"=>"ma", "30"=>"mu", "31"=>"na", "32"=>"or", "33"=>"o", "34"=>"p", "35"=>"gc", "36"=>"po", "37"=>"sa", "38"=>"tf", "39"=>"s", "40"=>"sg", "41"=>"se", "42"=>"so", "43"=>"t", "44"=>"te", "45"=>"to", "46"=>"v", "47"=>"va", "48"=>"bi", "49"=>"z", "50"=>"za", "51"=>"ce", "52"=>"ml"}
    if ["España", "Spain"].include? country
      return all_pcs[postal_code[0..1]] 
    else
      return province
    end
  end

  def self.invalid_record(u, row)
    logger = Logger.new("#{Rails.root}/log/users_invalid.log")
    logger.info "*" * 10
    logger.info u.errors.messages
    logger.info row
    raise "InvalidRecordError - #{u.errors.messages} - #{row}"
  end

  def self.process_row(row)
    now = DateTime.now
    u = User.new
    u.last_name = row[3][1]
    u.first_name = row[4][1]
    u.document_vatid = row[6][1] == "" ? row[7][1] : row[6][1]
    u.document_type = PodemosImport.convert_document_type(row[5][1], u.document_vatid)
    u.email = row[9][1]
    u.phone = row[10][1].sub('+','00')
    u.sms_confirmation_token = row[11][1]
    u.address = row[12][1]
    # legacy: un usuario puso una carta (literalmente)
    if row[13][1].length < 250 
      u.town = row[13][1]
    end
    u.postal_code = row[15][1]
    u.province = row[14][1]  #PodemosImport.convert_province row[15][1], row[16][1], row[14][1]
    u.country = row[16][1]  # PodemosImport.convert_country row[16][1]
    # legacy: al principio no se preguntaba fecha de nacimiento
    unless row[8][1] == ""
      u.born_at = Date.parse row[8][1] # 1943-10-15 
    end
    # legacy: al principio no se preguntaba para recibir la newsletter
    if row[18][1] == 1
      u.wants_newsletter = true
    end
    u.password = row[11][1]
    u.password_confirmation = row[11][1]
    u.confirmed_at = now
    u.sms_confirmed_at = now
    #u.has_legacy_password = true
    u.save
    unless u.valid? 
      PodemosImport.invalid_record(u, row)
    end
  end

  def self.init csv_file
    CSV.foreach(csv_file, headers: true, encoding: 'windows-1251:utf-8') do |row|
      Resque.enqueue(PodemosImportWorker, row)
    end
  end

end
