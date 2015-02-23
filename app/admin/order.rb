ActiveAdmin.register Order do
  scope_to Order, association_method: :full_view
  config.sort_order = 'updated_at_desc'

  menu :parent => "Colaboraciones"

  permit_params :status, :reference, :amount, :first, :payment_type, :payment_identifier, :payment_response, :payable_at, :payed_at, :created_at

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
  
  scope :to_be_paid
  scope :paid
  scope :warnings
  scope :errors
  scope :returned
  scope :deleted

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
        order.parent.get_user
      end
    end
    column :amount
    column :payable_at
    column :payed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :status_name
      row :user do |order|
        if order.user
          link_to(order.user.full_name, admin_user_path(order.user))
        elsif order.parent
          order.parent.get_user
        end
      end
      row :parent
      row :parent_type
      row :amount
      row :first
      row :reference
      row :payment_type
      row :payment_identifier
      row :payment_response
      row :created_at
      row :updated_at
      row :payable_at
      row :payed_at
      row :deleted_at
    end
    active_admin_comments
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

  member_action :return_order do
    if resource.is_paid?
      resource.mark_as_returned!
    end
    redirect_to admin_order_path(id: resource.id)
  end

  action_item only: :show do
    if resource.is_paid?
      link_to 'Orden devuelta', return_order_admin_order_path(id: resource.id), data: { confirm: "Esta orden no será contabilizada como cobrada. ¿Deseas continuar?" }
    end
  end

end
