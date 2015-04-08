ActiveAdmin.register Notice do
  menu :parent => "Users"

  permit_params :title, :body, :link, :created_at

  index do
    selectable_column
    id_column
    column :title
    column :link
    column :created_at
    actions
  end

  filter :title
  filter :created_at

  show do
    attributes_table do
      row :title
      row :body
      row :link
      row :send do
        if notice.has_sent
          link_to "Ya se ha enviado", "#", disabled: :disabled, class: "button disabled"
        else
          link_to "Enviar a #{NoticeRegistrar.all.count} usuario móviles y #{User.all.count} usuarios web", broadcast_admin_notice_path(notice), class: "button", method: :post
        end
      end
      row :sent_at
    end
    active_admin_comments
  end

  member_action :broadcast, :method => :post do
    notice = Notice.find(params[:id])
    notice.broadcast!
    redirect_to({action: :show }, {:notice => "Se ha enviado el Aviso"})
  end

  form do |f|
    f.inputs "Aviso" do
      f.input :title
      f.input :link
      f.input :body
    end
    f.actions
  end

end
