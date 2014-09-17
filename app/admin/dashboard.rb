ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel "Últimos usuarios dados de alta" do
          ul do
            User.limit(15).map do |user|
              li link_to(user.full_name, admin_user_path(user)) + "- #{user.created_at}"
            end
          end
        end
      end

      column do
        panel "Notificaciones" do
          link_to("Enviar notificación a todos", new_admin_notice_path, class: "button") 
        end
      end
    end
  end
end
