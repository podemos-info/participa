ActiveAdmin.register Group do
  menu :parent => "Users"

  permit_params :name, :description

  filter :name
  filter :description
  filter :created_at

  show do
    authorize! :admin, group
    attributes_table do
      row :name
      row :description
      row :users do 
        group.users.map { |u| link_to u.full_name, admin_user_path(u)}.join(' ,').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

end
