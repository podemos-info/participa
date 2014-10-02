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
      row :wants_newsletter
    end
    active_admin_comments
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form partial: "form"

end
