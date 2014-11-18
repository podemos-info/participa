ActiveAdmin.register Collaboration do
  permit_params :amount, :frequency

  scope :credit_cards
  scope :bank_nationals
  scope :bank_internationals

  index do
    selectable_column
    id_column
    column :user
    column :amount
    column :frequency
    column :payment_type_name
    column :created_at
    actions
  end

  filter :user
  filter :amount
  filter :frequency
  filter :created_at

  show do |collaboration|
    attributes_table do 
      row :user
      row :payment_type_name
      row :amount do
        number_to_euro collaboration.amount
      end
      row :frequency do
        "cada #{collaboration.frequency} días"
      end
      row :created_at 
      row :updated_at 
      if collaboration.is_credit_card? 
        row :order_id do 
          collaboration.order_id
        end
      end
      if collaboration.is_bank_national? 
        row :ccc_full
      end
      if collaboration.is_bank_international? 
        row :iban_account
        row :iban_bic
      end
    end
    active_admin_comments
  end

  collection_action :download_bank_national, :method => :get do
    collaborations = Collaboration.bank_nationals
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      collaborations.each { |c| csv << [ c.ccc_full ] }
    end
    send_data csv.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.bank_national.#{Date.today.to_s}.csv"
  end

  collection_action :download_bank_international, :method => :get do
    collaborations = Collaboration.bank_internationals
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      collaborations.each { |c| csv << [ c.iban_bank, c.iban_bic ] }
    end
    send_data csv.encode('utf-8'),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.bank_international.#{Date.today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar CSV de Bancos Nacionales', params.merge(:action => :download_bank_national))
  end 

  action_item only: :index do
    link_to('Descargar CSV de Bancos Internacionales', params.merge(:action => :download_bank_international))
  end 

  form do |f|
    f.inputs "Colaboración" do
      f.input :user #, input_html: {disabled: true}
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS # , input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES #, input_html: {disabled: true}
    end
    f.actions
  end

end
