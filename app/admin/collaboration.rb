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

  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES
  filter :payment_type, :as => :select, :collection => Order::TYPES
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS
  filter :created_at

  show do |collaboration|
    attributes_table do
      row :user
      row :payment_type_name
      row :amount do
        number_to_euro collaboration.amount
      end
      row :frequency_name
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
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS # , input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES #, input_html: {disabled: true}
      f.input :payment_type, as: :radio, collection: Collaboration::TYPES # , input_html: {disabled: true}
      f.input :ccc_entity
      f.input :ccc_office
      f.input :ccc_dc
      f.input :ccc_account
      f.input :iban_account
      f.input :iban_bic
    end
    f.actions
  end

end
