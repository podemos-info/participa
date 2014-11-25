ActiveAdmin.register Order do

  menu :parent => "Colaboraciones"

  actions :all, :except => [:new, :edit]

  # Nº RECIBO Es el identificador del cargo a todos los efectos y no se ha de repetir en la remesa y en las remesas sucesivas. Es un nº correlativo
  # NOMBRE  
  # DNI/NIE/PASAPORTE 
  # EMAIL 
  # DIRECCIÓN 
  # CIUDAD  
  # CÓDIGO POSTAL 
  # CODIGO PAIS Codigo ISO 3166-1 del Pais. Este campo tambien tendria que ser validado en el registro. Hay muchos errores al respecto. Incluso de puede hacer un desplegable con los codigos de cada pais
  # IBAN  Campo imprescindible cuando son cuentas en el extranjero
  # CCC los 20 digitos sin espacios
  # BIC/SWIFT Campo imprescindible cuando son cuentas en el extranjero
  # TOTAL Importe a pagar
  # CÓDIGO DE ADEUDO  Se pondra FRST cuando sea el primer cargo desde la fecha de alta, y RCUR en los siguientes sucesivos
  # URL FUENTE  "Este campo no se si existira en el nuevo entorno. Si no es asi poner por defecto https://podemos.info/participa/colaboraciones/colabora/
  # "
  # ID - ENTRADA  Codigo del colaborador en la base de datos
  # FECHA DE LA ENTRADA Fecha de alta en la base de datos
  # COMPROBACIÓN  Es el texto que aparecefrá en el recibo. Sera "Colaboracion "mes x"
  # FECHA TRIODOS Fecha de la remesa de recibos
  # FRECUENCIA  Perioricidad 
  # TITULAR Titular de la cuenta. Si no indican nada en contra se pondra el mismo que en "nombre". 
  #
  #"Nº RECIBO", "NOMBRE", "DNI/NIE/PASAPORTE", "EMAIL", "DIRECCIÓN", "CIUDAD", "CÓDIGO POSTAL", "CODIGO PAIS", "IBAN", "CCC", "BIC/SWIFT", "TOTAL", "CÓDIGO DE ADEUDO", "URL FUENTE", "ID - ENTRADA", "FECHA DE LA ENTRADA", "COMPROBACIÓN", "FECHA TRIODOS", "FRECUENCIA", "TITULAR"
  #1406013953  ANDRES ALABS ALABS  11111111T apereira@alabs.org  AVDA …  MADRID  28000 ES    12345678901234567890    10  RCUR  https://podemos.info/participa/colaboraciones/colabora/ 6728  14-06-2014  Colaboración octubre  07-10-2014  Mensual EMILIA CANSER
  #
  
  collection_action :mensual_orders, :method => :get do
    # TODO: only download orders for this month
    orders = Order.all
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      orders.each do |order| 
        # TODO: user.town_name 
        # FIXME: revisar
        csv << [ order.receipt, order.collaboration.user.full_name, order.collaboration.user.document_vatid, order.collaboration.user.email, order.collaboration.user.address, order.collaboration.user.town, order.collaboration.user.postal_code, order.collaboration.user.country, order.collaboration.iban_account, order.collaboration.ccc_full, order.collaboration.iban_bic, order.collaboration.amount, order.due_code, order.url_source, order.collaboration.id, order.created_at.to_s, order.concept, order.payable_at, order.collaboration.frequency_name, order.collaboration.user.full_name,  ] 
      end 
    end
    send_data csv.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.orders.#{Date.today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar orden de pago para este mes', params.merge(:action => :mensual_orders))
  end

  index do
    selectable_column
    id_column
    column :id
    column :status_name
    column :collaboration
    column :user do |order|
      link_to(order.collaboration.user.full_name, admin_user_path(order.collaboration.user))
    end
    column :payable_at
    column :payed_at
    column :created_at
    actions
  end

  filter :collaboration_user_email, as: :string
  filter :payable_at
  filter :payed_at
  filter :created_at
  
end
