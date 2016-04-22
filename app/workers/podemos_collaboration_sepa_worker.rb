class PodemosCollaborationSepaWorker

  @queue = :podemos_collaboration_sepa_queue

  def self.perform
    today = Date.today
    collaborations = Collaboration.joins(:order)
                     .includes(:user)
                     .where(payment_type: 2..3)
                     .merge(Order.by_date(today,today))
                     
    Rails.logger.info "=================================\n PodemosCollaborationSepaWorker\n#{collaborations.size} collaborations\n=================================\n"

		# First: Create the main object
		sdd = SEPA::DirectDebit.new(
		  # Name of the initiating party and creditor, in German: "Auftraggeber"
		  # String, max. 70 char
		  name: Rails.application.secrets.sepa['name'], # Entiendo que es el nombre con el que figura
                                                    # BCN en Comú en el banco

		  # OPTIONAL: Business Identifier Code (SWIFT-Code) of the creditor
		  # String, 8 or 11 char
		  bic: Rails.application.secrets.sepa['bic'], # Código BIC del banco de BCN en Comú

		  # International Bank Account Number of the creditor
		  # String, max. 34 chars
		  iban: Rails.application.secrets.sepa['iban'], # Número de cuenta en formato IBAN
                                                    # de BCN en Comú

		  # Creditor Identifier, in German: Gläubiger-Identifikationsnummer
		  # String, max. 35 chars
		  creditor_identifier: Rails.application.secrets.sepa['creditor_identifier'] # FIXME esto no se lo qué es
                                                                                 # Identificador de BCN en Comú en el banco
		)


    collaborations.each do |collaboration|

        # Second: Add transactions
        sdd.add_transaction(
          # Name of the debtor, in German: "Zahlungspflichtiger"
          # String, max. 70 char
          name:                      collaboration.user.full_name,  # Nombre de la persona
                                                                    # o entidad colaboradora

          # OPTIONAL: Business Identifier Code (SWIFT-Code) of the debtor's account
          # String, 8 or 11 char
          #bic:                       'SPUEDE2UXXX', # Código BIC del banco del colaborador

          # International Bank Account Number of the debtor's account
          # String, max. 34 chars
          iban:                      collaboration.calculate_iban, # Número de cuenta en formato IBAN
                                                                 # del colaborador

          # Amount in EUR
          # Number with two decimal digit
          amount:                    collaboration.amount, # Cantidad con la que colabora

          # OPTIONAL: Instruction Identification, will not be submitted to the debtor
          # String, max. 35 char
          #instruction:               '12345', # FIXME esto no se lo qué es

          # OPTIONAL: End-To-End-Identification, will be submitted to the debtor
          # String, max. 35 char
          #reference:                 'XYZ/2013-08-ABO/6789', # FIXME entiendo que es una referencia
                                                             # que generamos nosotros

          # OPTIONAL: Unstructured remittance information, in German "Verwendungszweck"
          # String, max. 140 char
          #remittance_information:    'Vielen Dank fur Ihren Einkauf!', # FIXME información de remesas.
                                                                       # Aclarar este campo.

          # Mandate identifikation, in German "Mandatsreferenz"
          # String, max. 35 char
          mandate_id: SecureRandom.hex, # Referencia del mandato
                                        # FIXME aclarar este campo

          # Mandate Date of signature, in German "Datum, zu dem das Mandat unterschrieben wurde"
          # Date
          mandate_date_of_signature: collaboration.created_at.to_date, # FIXME Fecha en la que se ha firmado el mandato

          # Local instrument, in German "Lastschriftart"
          # One of these strings:
          #   'CORE' ("Basis-Lastschrift")
          #   'COR1' ("Basis-Lastschrift mit verkürzter Vorlagefrist")
          #   'B2B' ("Firmen-Lastschrift")
          local_instrument: 'CORE', # FIXME aclarar este campo

          # Sequence type
          # One of these strings:
          #   'FRST' ("Erst-Lastschrift")
          #   'RCUR' ("Folge-Lastschrift")
          #   'OOFF' ("Einmalige Lastschrift")
          #   'FNAL' ("Letztmalige Lastschrift")
          sequence_type: 'OOFF', # FIXME aclarar este campo

          # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
          # Date
          #requested_date: Date.new(2013,9,5), # Fecha de vencimiento de la domiciliación bancaria

          # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
          # True or False
          #batch_booking: true # FIXME aclarar este campo

          # OPTIONAL: Use a different creditor account
          # CreditorAccount
          #creditor_account: SEPA::CreditorAccount.new(
          #  name:                'Creditor Inc.',
          #  bic:                 'RABONL2U',
          #  iban:                'NL08RABO0135742099',
          #  creditor_identifier: 'NL53ZZZ091734220000'
          #)
        )
      end

    File.open("/tmp/TRIODOS-SEPA.xml", 'w+') {|f| f.write(sdd.to_xml) } # Use latest schema pain.008.003.02
  end
end
