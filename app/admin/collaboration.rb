def show_collaboration_orders(collaboration, html_output = true)
  today = Date.today.unique_month
  output = (collaboration.get_orders(Date.today-6.months, Date.today+6.months).map do |orders|
    odate = orders[0].payable_at
    month = odate.month.to_s
    month = (html_output ? content_tag(:strong, month).html_safe : "|"+month+"|") if odate.unique_month==today
    month_orders = orders.map do |o|
      otext  = if o.has_errors?
                "x"
              elsif o.has_warnings?
                "!"
              elsif o.is_paid?
                "o"
              elsif o.was_returned?
                "d"
              elsif o.is_chargable? or not o.persisted?
                "_"
              else
                "~"
              end

      otext = link_to(otext, admin_order_path(o)).html_safe if o.persisted? and html_output
      otext
    end .join("")
    if html_output
      month + month_orders.html_safe
    else
      month + month_orders
    end
  end) .join(" ")

  html_output ? output.html_safe : output
end

ActiveAdmin.register Collaboration do
  scope_to Collaboration, association_method: :full_view
  config.sort_order = 'updated_at_desc'

  menu :parent => "Colaboraciones"

  permit_params  :status, :amount, :frequency, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, 
                :redsys_identifier, :redsys_expiration, :for_autonomy_cc, :for_town_cc

  actions :all, :except => [:new]

  scope :created, default: true
  scope :credit_cards
  scope :bank_nationals
  scope :bank_internationals
  scope :incomplete
  scope :recent
  scope :active
  scope :warnings
  scope :errors
  scope :legacy
  scope :non_user
  scope :deleted
  scope :autonomy_cc
  scope :town_cc

  index do
    selectable_column
    id_column
    column :user do |collaboration|
      if collaboration.user
        link_to(collaboration.user.full_name, admin_user_path(collaboration.user))
      else
        collaboration.get_user.full_name
      end
    end
    column :amount do |collaboration|
      number_to_euro collaboration.amount
    end
    column :orders do |collaboration|
      show_collaboration_orders collaboration
    end
    column :created_at do |collaboration|
      collaboration.created_at.strftime "%d-%m-%y"
    end
    column :method, sortable: 'payment_type' do |collaboration|
      collaboration.payment_type==1 ? "Tarjeta" : "Recibo"
    end
    column :territorial do |collaboration|
      status_tag("Cca") if collaboration.for_autonomy_cc
      status_tag("Ccm") if collaboration.for_autonomy_cc and collaboration.for_town_cc
    end
    column :info do |collaboration|
      status_tag("BIC", :error) if collaboration.is_bank? and collaboration.calculate_bic.nil?
      status_tag("Activo", :ok) if collaboration.is_active?
      status_tag("Alertas", :warn) if collaboration.has_warnings?
      status_tag("Errores", :error) if collaboration.has_errors?
      collaboration.deleted? ? status_tag("Borrado", :error) : ""
      if collaboration.redsys_expiration
        if collaboration.redsys_expiration<Date.today
          status_tag("Caducada", :error)
        elsif collaboration.redsys_expiration<Date.today+1.month
          status_tag("Caducará", :warn) 
        end
      end
    end
    actions
  end

  sidebar "Acciones", only: :index, priority: 0 do
    status = Collaboration.has_bank_file? Date.today
    h3 "Pagos con tarjeta" 
    ul do
      li link_to 'Cobrar tarjetas', params.merge(:action => :charge), data: { confirm: "Se enviarán los datos de todas las órdenes para que estas sean cobradas. ¿Deseas continuar?" }
    end

    h3 "Recibos"
    ul do
      li link_to 'Crear órdenes de este mes', params.merge(:action => :generate_orders), data: { confirm: "Este carga el sistema, por lo que debe ser lanzado lo menos posible, idealmente una vez al mes. ¿Deseas continuar?" }
      li link_to("Generar fichero para el banco", params.merge(:action => :generate_csv))
      if status[1]
        active = status[0] ? " (en progreso)" : ""
        li link_to("Descargar fichero para el banco#{active}", params.merge(:action => :download_csv))
      end
      li link_to "Marcar órdenes generadas como enviadas", params.merge(:action => :mark_as_charged), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" }
      li link_to "Marcar órdenes enviadas como pagadas", params.merge(:action => :mark_as_paid), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" }
    end
  end

  sidebar "Ayuda", only: :index do
    h3 "Nomenclatura de las órdenes"
    ul do
      li "_ = pendiente"
      li "~ = enviada"
      li "o = cobrada"
      li "! = alerta"
      li "x = error"
      li "d = devuelta"
    end
  end

  filter :user_document_vatid_or_non_user_document_vatid, as: :string
  filter :user_email_or_non_user_email, as: :string
  filter :status, :as => :select, :collection => Collaboration::STATUS.to_a
  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES.to_a
  filter :payment_type, :as => :select, :collection => Order::PAYMENT_TYPES.to_a
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS.to_a
  filter :created_at
  filter :for_autonomy_cc
  filter :for_town_cc

  show do |collaboration|
    attributes_table do
      row :user do
        collaboration.get_user
      end
      row :payment_type_name
      row :amount do
        number_to_euro collaboration.amount
      end
      row :frequency_name
      row :status_name
      row :created_at
      row :updated_at
      row :deleted_at
      
      row :ccc_full if collaboration.is_bank_national?
      row :iban_account if collaboration.is_bank_international?
      if collaboration.is_bank?
        row :iban_bic do
          status_tag(t("active_admin.empty"), :error) if collaboration.calculate_bic.nil?
          collaboration.calculate_bic
        end
      end
      if collaboration.is_credit_card?
        row :redsys_identifier
        row :redsys_expiration do
          collaboration.redsys_expiration.strftime "%m/%y" if collaboration.redsys_expiration
        end
      end
      row :territorial do
        status_tag("Cc autonómico") if collaboration.for_autonomy_cc
        status_tag("Cc municipal") if collaboration.for_autonomy_cc and collaboration.for_town_cc
      end
      row :info do
        status_tag("Cca", :ok) if collaboration.for_autonomy_cc
        status_tag("Ccm", :ok) if collaboration.for_autonomy_cc and collaboration.for_town_cc
        status_tag("Activo", :ok) if collaboration.is_active?
        status_tag("Alertas", :warn) if collaboration.has_warnings?
        status_tag("Errores", :error) if collaboration.has_errors?
        collaboration.deleted? ? status_tag("Borrado", :error) : ""
        if collaboration.redsys_expiration
          if collaboration.redsys_expiration<Date.today
            status_tag("Caducada", :error)
          elsif collaboration.redsys_expiration<Date.today+1.month
            status_tag("Caducará", :warn) 
          end
        end
      end
    end
    if collaboration.get_non_user
      panel "Colaboración antigua" do
        attributes_table_for collaboration.get_non_user do
          row :legacy_id 
          row :full_name
          row :document_vatid
          row :email
          row :address
          row :town_name
          row :postal_code
          row :country
          row :province
          row :phone 
        end
      end
    end
    panel "Órdenes de pago" do
      table_for collaboration.order.sort { |a,b| b.payable_at <=> a.payable_at } do
        column :id do |order|
          link_to order.id, admin_order_path(order.id)
        end
        column :status do |order|
          order.status_name
        end
        column :amount do |order|
          number_to_euro order.amount
        end
        column :payable_at  
        column :payed_at
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Colaboración" do
      f.input :user_id
      f.input :status, as: :select, collection: Collaboration::STATUS.to_a
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS.to_a #, input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES.to_a #, input_html: {disabled: true}
      f.input :payment_type, as: :radio, collection: Order::PAYMENT_TYPES.to_a #, input_html: {disabled: true}
      f.input :ccc_entity
      f.input :ccc_office
      f.input :ccc_dc
      f.input :ccc_account
      f.input :iban_account
      f.input :iban_bic
      f.input :redsys_identifier
      f.input :redsys_expiration
      f.input :for_autonomy_cc
      f.input :for_town_cc
    end
    f.actions
  end
  
  collection_action :charge, :method => :get do
    Collaboration.credit_cards.pluck(:id).each do |cid|
      Resque.enqueue(PodemosCollaborationWorker, cid)
    end
    redirect_to :admin_collaborations
  end

  collection_action :generate_orders, :method => :get do
    Collaboration.banks.pluck(:id).each do |cid|
      Resque.enqueue(PodemosCollaborationWorker, cid)
    end
    redirect_to :admin_collaborations
  end

  collection_action :generate_csv, :method => :get do
    Collaboration.bank_file_lock true
    Resque.enqueue(PodemosCollaborationWorker, -1)
    redirect_to :admin_collaborations
  end

  collection_action :download_csv, :method => :get do
    status = Collaboration.has_bank_file? Date.today
    if status[1]
      send_file Collaboration.bank_filename Date.today
    else
      flash[:notice] = "El fichero no existe aún"
    end
  end

  collection_action :mark_as_charged, :method => :get do
    Order.mark_bank_orders_as_charged!
  end

  collection_action :mark_as_paid, :method => :get do
    Order.mark_bank_orders_as_paid!
  end

  member_action :charge_order do
    resource.charge!
    redirect_to admin_collaboration_path(id: resource.id)
  end

  action_item only: :show do
    if resource.is_credit_card? 
      link_to 'Cobrar', charge_order_admin_collaboration_path(id: resource.id), data: { confirm: "Se enviarán los datos de la orden para que esta sea cobrada. ¿Deseas continuar?" }
    else
      link_to 'Generar orden', charge_order_admin_collaboration_path(id: resource.id)
    end
  end

  controller do
    def show
      @collaboration = Collaboration.with_deleted.find(params[:id])
      show! #it seems to need this
    end
  end

  csv do
    column :id
    column :full_name do |collaboration|
      collaboration.get_user.full_name
    end
    column :dni_nie do |collaboration|
      collaboration.get_user.document_vatid.upcase if collaboration.get_user.document_vatid
    end
    column :email do |collaboration|
      collaboration.get_user.email
    end
    column :address do |collaboration|
      collaboration.get_user.address
    end
    column :town do |collaboration|
      collaboration.get_user.town_name
    end
    column :postal_code do |collaboration|
      collaboration.get_user.postal_code
    end
    column :country do |collaboration|
      collaboration.get_user.country
    end
    column :frequency_name
    column :amount do |collaboration|
      collaboration.amount
    end
    column :total_amount do |collaboration|
      collaboration.amount * collaboration.frequency
    end
    column :payment_type_name
    column :ccc_full
    column :iban_account
    column :iban_bic do |collaboration|
      collaboration.calculate_bic
    end
    column :created_at
    column :info do |collaboration|
      if collaboration.has_errors?
        "Errores"
      elsif collaboration.has_warnings?
        "Alertas"
      else
        "OK"
      end
    end
    column :user do |collaboration|
      collaboration.user_id if collaboration.user_id
    end
    column :amount_current do |collaboration|
      collaboration.skip_queries_validations = true
      if collaboration.is_payable? and collaboration.must_have_order? Date.today
        (collaboration.amount/100 * collaboration.frequency) 
      else
        0
      end
    end
    column :orders do |collaboration|
      show_collaboration_orders collaboration, false
    end
  end
end
