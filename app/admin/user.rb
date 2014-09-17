ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :document_type
      f.input :document_vatid
      f.input :born_at
      f.input :address
      f.input :town
      f.input :postal_code
      f.input :province
      f.input :country
      f.input :wants_newsletter
    end
    f.actions
  end

end
