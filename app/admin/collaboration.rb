ActiveAdmin.register Collaboration do
#  permit_params :amount, :frequency

  menu :parent => "Colaboraciones"

  actions :all, :except => [:new, :edit]

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
    column :frequency_name
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
      if collaboration.is_bank_national?
        row :ccc_full
      end
      if collaboration.is_bank_international?
        row :iban_account
        row :iban_bic
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
      f.input :user #, input_html: {disabled: true}
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS.to_a # , input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES.to_a #, input_html: {disabled: true}
      f.input :payment_type, as: :radio, collection: Order::PAYMENT_TYPES.to_a # , input_html: {disabled: true}
      f.input :ccc_entity
      f.input :ccc_office
      f.input :ccc_dc
      f.input :ccc_account
      f.input :iban_account
      f.input :iban_bic
    end
    f.actions
  end
  
  collection_action :generate_orders, :method => :get do
    # TODO: only download orders for this month
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      Collaboration.banks.find_each do |collaboration|
        order = collaboration.generate_order Date.today
        if order
          csv << [ order.id, order.user.full_name, order.user.document_vatid, order.user.email, order.user.address, 
                  order.user.town_name, order.user.postal_code, order.user.country, 
                  collaboration.iban_account, collaboration.ccc_full, collaboration.iban_bic, 
                  order.amount, order.due_code, order.url_source, order.parent.id, order.created_at.to_s, 
                  order.reference, order.payable_at, collaboration.frequency_name, order.user.full_name ] 
        end
      end 
    end
    send_data csv.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.orders.#{Date.today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar órdenes de pago por transferencia', params.merge(:action => :generate_orders))
  end
end
