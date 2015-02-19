ActiveAdmin.register Collaboration do
  menu :parent => "Colaboraciones"

  permit_params  :amount, :frequency, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, 
                :redsys_identifier, :redsys_expiration

  actions :all, :except => [:new]

  scope :all
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
  scope :only_deleted

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
      today = Date.today.unique_month
      (collaboration.get_orders(Date.today-6.months, Date.today+6.months).map do |orders|
        odate = orders[0].payable_at
        text = (odate.unique_month==today ? "&gt;" : "") + odate.month.to_s

        text + orders.map do |o|
          otext = if o.has_errors?
                    "x"
                  elsif o.has_warnings?
                    "!"
                  elsif o.is_paid?
                    "o"
                  else
                    "."
                  end
          otext = link_to(otext, admin_order_path(o)) if o.persisted?
          otext
        end .join("")
      end) .join(" ").html_safe
    end
    column :dni do |collaboration|
      collaboration.get_user.document_vatid
    end
    column :created_at
    column :method, sortable: 'payment_type' do |collaboration|
      collaboration.payment_type==1 ? "Tarjeta" : "Transferencia"
    end
    column :info do |collaboration|
      status_tag("Activo", :ok) if collaboration.is_active?
      status_tag("Alertas", :warn) if collaboration.has_warnigs?
      status_tag("Errores", :error) if collaboration.has_errors?
      collaboration.deleted? ? status_tag("Borrado", :error) : ""
    end
    actions
  end

  filter :user_document_vatid_or_non_user_document_vatid, as: :string
  filter :user_email_or_non_user_email, as: :string
  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES.to_a
  filter :payment_type, :as => :select, :collection => Order::PAYMENT_TYPES.to_a
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS.to_a
  filter :created_at

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
      if collaboration.is_bank_national?
        row :ccc_full
      end
      if collaboration.is_bank_international?
        row :iban_account
        row :iban_bic
      end
      if collaboration.is_credit_card?
        row :redsys_identifier
        row :redsys_expiration
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
      table_for collaboration.order do
        column :id do |order|
          link_to order.id, admin_order_path(order.id)
        end
        column :status do |order|
          order.status_name
        end
        column :payable_at  
        column :payed_at
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Colaboración" do
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
      f.input :non_user_data
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

  action_item only: :index do
    link_to('Cobrar tarjetas', params.merge(:action => :charge))
  end
  action_item only: :index do
    link_to('Generar órdenes bancos', params.merge(:action => :generate_orders))
  end

  collection_action :download, :method => :get do
    today = Date.today
    output = CSV.generate(encoding: 'utf-8', force_quotes: true) do |csv|
      Collaboration.joins(:order).includes(:user).where.not(payment_type: 1).merge(Order.by_date(today,today)).find_each do |collaboration|
        bank_data = collaboration.get_bank_data today
        csv << bank_data if bank_data
      end
    end
    send_data output.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.orders.#{today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar fichero de pagos de este mes', params.merge(:action => :download))
  end

  member_action :charge_order do
    resource.charge!
    redirect_to admin_collaboration_path(id: resource.id)
  end

  action_item only: :show do
    link_to 'Cobrar / generar orden', charge_order_admin_collaboration_path(id: resource.id)
  end

  controller do
    def show
      @collaboration = Collaboration.with_deleted.find(params[:id])
      show! #it seems to need this
    end
  end

end
