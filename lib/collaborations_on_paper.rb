class CollaborationsOnPaper
  include ActiveModel::Validations::SpanishVatValidatorsHelpers

  DEFAULT_STATUS = 2
  DEFAULT_COUNTRY = 'ES'
  SUPPORT_FOR_TOWN ='CCM'
  SUPPORT_FOR_AUTONOMY ='CCA'
  SUPPORT_FOR_COUNTRY ='CCE'
  SUPPORT_FOR_ISLAND ='CCI'

  attr_accessor :logging_to_file
  attr_reader :collaborations_processed
  attr_reader :results
  attr_reader :errors_on_save

  def initialize(csv_file, col_sep = "\t")
    @headers = {
      name: 'NOMBRE',
      surname1: 'APELLIDO 1',
      surname2: 'APELLIDO 2',
      dni: 'DNI',
      born: 'FECHA DE NACIMIENTO',
      phone: 'TELEFONO MOVIL',
      email: 'EMAIL',
      gender: 'GENERO',
      address: 'DOMICILIO',
      town_name: 'MUNICIPIO',
      postal_code: 'CODIGO POSTAL',
      province: 'PROVINCIA',
      amount: 'IMPORTE MENSUAL',
      iban_code: 'CODIGO IBAN',
      swift_code: 'BIC/SWIFT', # NO EXISTENTE NI NECESARIO EN LOS ÚLTIFOMS FICHEROS PUES SE PUEDE CALCULAR A PARTIR DEL IBAN
      entity_code: 'ENTIDAD',
      office_code: 'OFICINA',
      cc_code: 'CC',
      acount_code: 'CUENTA',
      ine_town: 'MUNICIPIO INE',
      donation_type: 'FINANCIACION TERRITORIAL',
      payment_type: 'METODO DE PAGO',
      payment_frecuency: 'FRECUENCIA DE PAGO',
      created_at: 'CREADO'
      }
    @logging_to_file = false
    @collaborations_processed = []
    @results = []
    @errors_on_save = []
    @fields = {}

    CSV.foreach(csv_file, {:headers => true, :col_sep => col_sep}) do |row|
      @fields = get_fields row
      process_row
    end

    save_collaborations if all_ok?
  end

  def all_ok?
    @results.all?{|r| (r[1] == :ok || r[1] == :ok_non_user)}
  end

  def has_errors_on_save?
    @errors_on_save.count.positive?
  end

  private

  def get_fields(row,headers = @headers )
    { document_vatid: row[headers[:dni]].strip.upcase,
      full_name: row[headers[:surname1]] || row[headers[:surname2]] ? "#{row[headers[:name]]} #{row[headers[:surname1]]} #{row[headers[:surname2]]}" : row[headers[:name]],
      email: row[headers[:email]],
      ccc_1: row[headers[:entity_code]],
      ccc_2: row[headers[:office_code]],
      ccc_3: row[headers[:cc_code]],
      ccc_4: row[headers[:acount_code]],
      iban_1: row[headers[:iban_code]],
      iban_2: row[headers[:swift_code]] || '',
      payment_type: row[headers[:payment_type]] || 2,
      amount: row[headers[:amount]].to_i * 100.0,
      frequency: row[headers[:payment_frecuency]] || 1,  # 1 3 12
      created_at: row[headers[:created_at]] ? DateTime.parse(row[headers[:created_at]]) : DateTime.now,
      address: row[headers[:address]] || '',
      town_name: row[headers[:town_name]],
      ine_town: row[headers[:ine_town]],
      postal_code: row[headers[:postal_code]],
      province: row[headers[:province]],
      phone: row[headers[:phone]],
      gender: row[headers[:gender]],
      donation_type: row[headers[:donation_type]],
      row: row,
      user: nil
    }
  end

  def process_row
    user1 = User.find_by_email @fields[:email]
    user2 = User.find_by_document_vatid @fields[:document_vatid] unless user1
    return add_error(:vatid_invalid) if user1 &&  has_invalid_vatid(user1)
    return add_error(:email_invalid) if user2 && has_invalid_fullname(user2)
    @fields[:document_vatid] = user1.document_vatid if user1 && vatid_invalid?(user1) && validate_collaboration_full_name(user1)
    @fields[:email] = user2.email if user2 && validate_collaboration_full_name(user2)
    @fields[:user] = user1 || user2
    return add_error(:vatid_invalid) unless (user1 || user2) || (@fields[:document_vatid] && validate_nif(@fields[:document_vatid]))

    add_collaboration
  end

  def add_collaboration
    c = Collaboration.new
    c.user = @fields[:user]

    unless c.user
      info= {
        full_name: @fields[:full_name],
        document_vatid: @fields[:document_vatid],
        email: @fields[:email],
        address: @fields[:address],
        town_name: @fields[:town_name],
        postal_code: @fields[:postal_code],
        province: @fields[:province],
        phone: @fields[:phone],
        gender: @fields[:gender],
        country: DEFAULT_COUNTRY,
        ine_town: @fields[:ine_town]
      }

      c.set_non_user info
    end

    c.amount = @fields[:amount]
    c.frequency = @fields[:frequency]
    c.created_at = @fields[:created_at]
    c.payment_type = @fields[:payment_type]
    c.ccc_entity = @fields[:ccc_1]
    c.ccc_office = @fields[:ccc_2]
    c.ccc_dc = @fields[:ccc_3]
    c.ccc_account = @fields[:ccc_4]
    c.iban_account = @fields[:iban_1]
    c.iban_bic = c.calculate_bic
    c.status = DEFAULT_STATUS

    case @fields[:donation_type]
    when SUPPORT_FOR_TOWN
      c.for_town_cc = true
    when SUPPORT_FOR_AUTONOMY
      c.for_autonomy_cc = true
    when SUPPORT_FOR_COUNTRY
      c.for_town_cc = false
      c.for_island_cc = false
      c.for_autonomy_cc = false
    when SUPPORT_FOR_ISLAND
      c.for_island_cc = true
    end
    status = c.user ? :ok : :ok_non_user
    @collaborations_processed.push(c)
    @results.push([@fields,status])
  end

  def save_collaborations
    filename = "#{Rails.root}/log/collaboration/results.txt"
    ActiveRecord::Base.transaction do
      @collaborations_processed.each do |c|
        if c.valid?
          c.save!
          data = "#{@fields[:row]}; 'user_valid'" if c.user
          data = "#{@fields[:row]}; 'non_user_valid'" unless c.user
        else
          @errors_on_save.push [c.errors.messages.to_s,@fields[:row]]
          data = "#{@fields[:row]};#{c.errors.messages.to_s} ; 'user_error'" if c.user
          data = "#{@fields[:row]};#{c.errors.messages.to_s} #{c.created_at}; 'non_user_error'" unless c.user
        end
        open_log_to_file filename, data if logging_to_file
      end
    end
  end

  def open_log_to_file(filename, text)
    File.open(filename, 'a') { |f| f.write(text) }
  end

  def add_error(error)
    @collaborations_processed.push(nil)
    @results.push([@fields, error])
  end

  def has_valid_vatid(user)
    validate_collaboration_vatid(user) || validate_collaboration_full_name(user)
  end

  def has_invalid_vatid(user)
    !has_valid_vatid user
  end

  def validate_collaboration_vatid(user)
    user.document_vatid == @fields[:document_vatid]
  end

  def vatid_invalid?(user)
    !validate_collaboration_vatid user
  end

  def validate_collaboration_full_name(user)
    user.full_name.downcase == @fields[:full_name].downcase
  end

  def has_invalid_fullname(user)
    !validate_collaboration_full_name user
  end
end