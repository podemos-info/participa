ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :first_name, :last_name, :document_type, :document_vatid, :born_at, :address, :town, :postal_code, :province, :country, :wants_newsletter

  index do
    selectable_column
    id_column
    column :email
    column :circle
    column :sign_in_count
    column :created_at
    actions
  end

  show do 
    attributes_table do
      row :first_name
      row :last_name
      row :document_type do 
        user.document_type_name
      end
      row :document_vatid
      row :born_at
      row :email
      row :town
      row :postal_code
      row :province do
        user.province_name
      end
      row :country do
        user.country_name
      end
      raw :circle
      row :created_at
      row :confirmation_sent_at
      row :confirmed_at
      row :unconfirmed_email
      row :has_legacy_password
      row :sms_confirmation_token
      row :confirmation_sms_sent_at
      row :sms_confirmed_at
      row :failed_attempts
      row :locked_at
    end
    active_admin_comments
  end

  filter :last_name
  filter :email
  filter :document_vatid
  filter :admin
  filter :born_at
  filter :created_at
  filter :town
  filter :postal_code
  filter :province
  filter :country
  filter :circle

  form partial: "form"

  collection_action :download_newsletter_csv, :method => :get do
    users = User.wants_newsletter
    csv = CSV.generate(encoding: 'utf-8') do |csv|
      users.each { |user| csv << [ user.email ] }
    end
    send_data csv.encode('utf-8'), 
      type: 'text/csv; charset=utf-8; header=present', 
      disposition: "attachment; filename=podemos.newsletter.#{Date.today.to_s}.csv"
  end

  action_item only: :index do
    link_to('Descargar correos para Newsletter (CSV)', params.merge(:action => :download_newsletter_csv))
  end 

end
