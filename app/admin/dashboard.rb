ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Aviso legal" do 
          div do 
            "Aviso importante a todos los usuarios"
          end
          div do
            link_to "Leer Aviso Legal", "/pdf/aviso_legal.pdf", target: "_blank"
          end
        end
      end
    end
    columns do
      column do
        panel "Últimos usuarios dados de alta" do
          ul do
            User.limit(30).map do |user|
              li link_to(user.full_name, admin_user_path(user)) + "- #{user.created_at}"
            end
          end
        end
      end
      column do
        div do
          panel "Avisos" do
            ul do
              Notice.limit(5).map do |notice|
                li link_to(notice.title, admin_notice_path(notice)) +  "- #{notice.created_at}"
              end
            end
            div do
              link_to("Enviar aviso a todos", new_admin_notice_path, class: "button") 
            end
          end
        end
        div do
          panel "Elecciones" do
            ul do
              Election.limit(5).map do |election|
                li link_to(election.title, admin_election_path(election)) +  "- #{election.created_at}"
              end
            end
            div do
              link_to("Dar de alta nueva elección", new_admin_election_path, class: "button") 
            end
          end
        end
      end
    end
  end
end
