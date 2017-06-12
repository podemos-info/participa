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
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs
    panel "Usuaris" do 
      para "Pon aqui los emails de los usuarios que quieras agregar a este grupo."
      f.input :members, as: :text, label: false
    end
    f.actions
  end

  after_save do |group|
    members = params[:group][:members]
    if members.length > 0 
      emails = members.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)
      if emails.count > 0 
        users = User.where(email: emails)
        users.each do |u| 
          u.groups << group
          u.save
        end
        flash[:notice] = "Se han agregado #{users.count} usuarios al grupo: #{users.pluck :email}"
      else
        flash[:error] = "No se ha encontrado ningun usuario con esos correos electronicos. Comprueba los correos #{members}"
      end
    end
  end

end
