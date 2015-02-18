ActiveAdmin.register Order do

  menu :parent => "Colaboraciones"

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
  #

  index do
    selectable_column
    id_column
    column :id
    column :status_name
    column :parent
    column :user do |order|
      if order.user
        link_to(order.user.full_name, admin_user_path(order.user))
      elsif order.parent
        order.parent.get_user.full_name
      end
    end
    column :payable_at
    column :payed_at
    column :created_at
    actions
  end

  filter :user_email, as: :string
  filter :payable_at
  filter :payed_at
  filter :created_at
  
  form do |f|
    f.inputs "Order" do
      f.input :status, as: :select, collection: Order::STATUS.to_a
      f.input :reference
      f.input :amount
      f.input :first
      f.input :payment_type
      f.input :payment_identifier
      f.input :payment_response
      f.input :payable_at
      f.input :payed_at
      f.input :created_at
    end
    f.actions
  end
  
end
