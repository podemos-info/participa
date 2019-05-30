namespace :cmd_get_data do
  desc 'Get phones from users using parameter'
  task :phones => :environment do

    def valid_json?(json)
      JSON.parse(json)
      return true
      rescue JSON::ParserError => e
      return false
    end

    def validate_phone (phone_to_validate)
        min_phone_number = 34600000000
        max_phone_number = 34799999999
        correct_phone_length = 9
        phone_prefix = "34"
      
        phone = phone_to_validate.to_i.to_s
        lon = phone.length
        phone =  lon == correct_phone_length ? phone_prefix + phone : phone 
        number_phone = phone.to_i
        correct= (number_phone > min_phone_number and number_phone < max_phone_number)
      return phone,correct
    end

    # telefonos de gente que no ha votado y puede votar
    # options[:election_id] = 90               #  Id del proceso Electoral (Opcional)
    # options[:foreign] = false                # si es true, sólo cargara los datos de personas que vivan fuera de españa
    # options[:cccaa]="c_13"                   # CCAA Si se elíge este campo, Anula
    # options[:province]="28"
    # options[:town]="m_28_079_6"  o un array de municipios ["m_28_079_6", "m_33_012_3"]                      # Municipio del que se quieren los eléfonos, o se pone algo en este campo o en el anterior
    # options[:postal_code] = "28044"          # Código Postal 
    # options[:filename] = "phones-navarra"    # Nombre de fichero a crear
    # options[:active] = false                 # si sólo se quieren telefonos de usuarios activos se pondria "true", en caso contrario "false"
    # options[:with_date] = false              # este campo indica si aparece un campo fecha en el fichero a exportar
    # options[:with_phone_validation] = false  # Este campo indica si se quiere que la aplicación extraiga unicamente los telefonos con un determinado patrón de validación
    # options[:vote_town_validated] = false    # Este campo indica si quiere que se valide el terriotio a fecha de cierre de censo de las personas cuyos teléfonos van a exportarse
    # options[:verified] = false               # Este campo indica si se quiere que se saquen sólo los teléfonos de las personas que aún no han solicitado la verificación de sus datos
    # options[:verified] = true                # Este campo indica si se quiere que se saquen sólo los teléfonos de las personas ya verificadas
    # options[:split_each] = 45000

    def get_phones_to_sms(options)
      return unless options.keys.count > 1
        
      options[:town] = JSON.parse(options[:town]) if options[:town] && valid_json?(options[:town])
      options[:cccaa] = JSON.parse(options[:cccaa]) if options[:cccaa] && valid_json?(options[:cccaa])
      options[:postal_code] = JSON.parse(options[:postal_code]) if options[:postal_code] && valid_json?(options[:postal_code]) 

      if options.has_key?(:ayuda)
        ayuda = "telefonos de gente que no ha votado y puede votar\n--help muestra esta ayuda\n--election_id=90               #  Id del proceso Electoral (Opcional)\n--foreign=false                # si es true, sólo cargara los datos de personas que vivan fuera de españa\n--cccaa='c_13'                   # CCAA Si se elíge este campo, Anula\n--province='28'\n--town='m_28_079_6'  o un array de municipios ['m_28_079_6', 'm_33_012_3']                      # Municipio del que se quieren los eléfonos, o se pone algo en este campo o en el anterior\n--postal_code='28044'          # Código Postal \n--filename='phones-navarra'    # Nombre de fichero a crear\n--active=false                 # si sólo se quieren telefonos de usuarios activos se pondria 'true', en caso contrario 'false'\n--with_date=false              # este campo indica si aparece un campo fecha en el fichero a exportar\n--with_phone_validation=false  # Este campo indica si se quiere que la aplicación extraiga unicamente los telefonos con un determinado patrón de validación\n--vote_town_validated=false    # Este campo indica si quiere que se valide el terriotio a fecha de cierre de censo de las personas cuyos teléfonos van a exportarse\n--verified=false               # Este campo indica si se quiere que se saquen sólo los teléfonos de las personas que aún no han solicitado la verificación de sus datos\n--verified=true                # Este campo indica si se quiere que se saquen sólo los teléfonos de las personas ya verificadas\n--split_each=45000"
        puts ayuda
        exit
      end
      ids=[]
      i = 0
      
      e = Election.find(options[:election_id]) if options[:election_id].present?
      ends = Date.today 
      ends = e.user_created_at_max if e
      ids = e.votes.pluck(:user_id) if options[:election_id].present? 
      year_ago = (Date.today - 1.year).to_date
      
      data =User.confirmed.not_banned
      data = data.where("current_sign_in_at >= ? and created_at <= ?",year_ago, ends) if options[:active].present?
      
      data = data.where("country <> 'ES'") if options[:foreign].present?
      spain = Carmen::Country.coded("ES") if options[:foreign].blank? && options[:cccaa].present?
      if options[:cccaa] && spain
        towns = []
        options[:cccaa].each do |ccaa|
          midata = Podemos::GeoExtra::AUTONOMIES.map { |k,v| spain.subregions[k[2..3].to_i-1].subregions.map {|r| r.code } if v[0] == ccaa } .compact.flatten
          towns += midata
        end
      end
      #towns = Podemos::GeoExtra::AUTONOMIES.map { |k,v| spain.subregions[k[2..3].to_i-1].subregions.map {|r| r.code } if v[0]==options[:cccaa] } .compact.flatten if spain
      data = data.where(vote_town:towns) if spain  
      data = data.where("vote_town ilike ?",'m_'+options[:province]+"%") if options[:foreign].blank? && options[:cccaa].blank? && options[:province].present?    
      data = data.where(vote_town:options[:town]) if options[:foreign].blank? && options[:cccaa].blank? && options[:province].blank? && options[:town].present?
      data = data.where(postal_code:options[:postal_code]) if options[:foreign].blank? && options[:cccaa].blank? && options[:province].blank? && options[:town].blank? && options[:postal_code].present?

      results = []
      data.each do |u|
        i+=1
        print("\r#{i}") if i%100==0
        next if ids.include?(u.id) || (options[:verified] == u.not_verified)
            
        phone,correct = validate_phone(u.phone) if options[:with_phone_validation].present?      
        phone = u.phone.to_i if options[:with_phone_validation].blank?
        correct = true if options[:with_phone_validation].blank?      

        mi_date = 0
        mi_date = u.current_sign_in_at.strftime("%d/%m/%Y") if u.current_sign_in_at
        result = options[:with_date].present? ? [mi_date, phone] : [phone] if correct
        u10 = u.version_at(ends) if options[:vote_town_validated].present?
        result = (result if (u10 && u10.vote_autonomy_code!="" && u10.vote_autonomy_code == options[:cccaa]) || (u10 && u10.vote_town !="" && u10.vote_town == options[:town])) if options[:vote_town_validated]
        results.push result
      end

      if options[:election_id].present?
        ids2 = e.votes.pluck(:user_id)
        phones = User.confirmed.not_banned.where(id: ids2).pluck(:phone)
        phones = phones.map {|ph| validate_phone(ph)[0]}
        results = results - phones
      end
      export_raw_data options[:filename],results  do |ph|
        ph
      end

      split_each = options[:split_each] || 45000
      full_file_name = "tmp/export/#{options[:filename]}"
      command = "split -l #{split_each} --numeric-suffixes --additional-suffix=.csv #{full_file_name}.tsv #{full_file_name}"
      result_command = system(command) if i > split_each

      puts i
    end

    args = Hash[ARGV.flat_map{|s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) }]
    args.symbolize_keys!
    get_phones_to_sms args
  end
end