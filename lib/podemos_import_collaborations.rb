class PodemosImportCollaborations

  def log_to_file(filename, text)
    File.open(filename, 'a') { |f| f.write(text) }
  end

  def self.process_row(row)
    document_vatid = row[2]
    email = row[3]
    ccc_entity = row[11] # entity
    ccc_office = row[12] # office
    ccc_3 = row[13]      # dc
    ccc_4 = row[14]      # account
    iban_1 = row[18]     # iban_account
    iban_2 = row[19]     # iban_bic
    payment_type = row[10]
    amount = row[20]
    frequency = row[22]

    # TODO: strip and upcase iban_account/iban_bic

    if User.exists?(email: email)
      user = User.find_by_email email
      # comprobamos que su DNI sea el mismo en colabora y participa
      if user.document_vatid == document_vatid 
        c = Collaboration.new 
        c.user = user
        c.amount = amount
        c.frequency = frequency
        case payment_type
        when "Suscripción con Tarjeta de Crédito/Débito"
          c.payment_type = 1
        when "Domiciliación en cuenta bancaria (CCC)"
          c.payment_type = 2
          c.ccc_entity = ccc_1
          c.ccc_office = ccc_2
          c.ccc_dc = ccc_3
          c.ccc_account = ccc_4
        when "Domiciliación en cuenta extranjera (IBAN)"
          c.payment_type = 3
          c.iban_account = iban_1
          c.iban_bic = iban_2
        else 
          log_to_file "#{Rails.root}/log/collaboration/not_payment_type.txt", email
        end
        if c.valid?
          c.save
        else
          log_to_file "#{Rails.root}/log/collaboration/not_valid.txt", email
        end
      else
        log_to_file "#{Rails.root}/log/collaboration/not_document.txt", email
      end
    else
      log_to_file "#{Rails.root}/log/collaboration/not_participation.txt", email
    end
  end

  def self.init csv_file
    # FIXME: delete directory
    File.delete("#{Rails.root}/log/collaboration/") 
    CSV.foreach(csv_file, headers: true) do |row|
      process_row row
    end
  end

end
