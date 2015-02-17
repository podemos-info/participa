ActiveAdmin.register Collaboration do
  menu :parent => "Colaboraciones"

  permit_params  :amount, :frequency, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, 
                :redsys_identifier, :redsys_expiration

  actions :all, :except => [:new]

  scope :credit_cards
  scope :bank_nationals
  scope :bank_internationals

  index do
    selectable_column
    id_column
    column :user
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
                    "_"
                  end
          otext = link_to(otext, admin_order_path(o)) if o.persisted?
          otext
        end .join("")
      end) .join(" ").html_safe
    end
    column :payment_type_name
    column :created_at
    actions
  end

  filter :user_email, as: :string
  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES.to_a
  filter :payment_type, :as => :select, :collection => Order::PAYMENT_TYPES.to_a
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS.to_a
  filter :created_at

  show do |collaboration|
    attributes_table do
      row :user
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
    end
    f.actions
  end
  
  collection_action :charge, :method => :get do
    Collaboration.all.select(:id).find_each do |collaboration|
      Resque.enqueue(PodemosCollaborationWorker, collaboration.id)
    end
    redirect_to :admin_collaborations
  end

  action_item only: :index do
    link_to('Cobrar colaboraciones', params.merge(:action => :charge))
  end

  collection_action :download, :method => :get do
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      Collaboration.joins(:order).includes(:user).where.not(payment_type: 1).merge(Order.by_date(Date.today-1.month,Date.today-1.month)).find_each do |collaboration|
        order = collaboration.order[0]
        csv << [ "%0d%0d%0d" % [ Date.today.year%100, Date.today.month, order.id%1000000 ], 
                collaboration.user.full_name.mb_chars.upcase.to_s, collaboration.user.document_vatid.upcase, collaboration.user.email, 
                collaboration.user.address.mb_chars.upcase.to_s, collaboration.user.town_name.mb_chars.upcase.to_s, 
                collaboration.user.postal_code, collaboration.user.country.upcase, 
                collaboration.iban_account, collaboration.ccc_full, collaboration.iban_bic, 
                order.amount/100, order.due_code, order.url_source, collaboration.id, 
                order.created_at.strftime("%d-%m-%Y"), order.reference, order.payable_at.strftime("%d-%m-%Y"), 
                collaboration.frequency_name, collaboration.user.full_name ] if not user.deleted? and order.is_payable?
      end
    end
    send_data csv.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.orders.#{Date.today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar fichero de pagos de este mes', params.merge(:action => :download))
  end

  member_action :charge_order do
    resource.charge
    redirect_to :admin_collaborations
  end

  action_item only: :show do
    link_to 'Cobrar', charge_order_admin_collaboration_path(id: resource.id)
  end
end
