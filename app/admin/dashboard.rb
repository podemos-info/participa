ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Información importante" do 
          div "Condiciones de uso y aviso legal"
          div "Manual de uso de la aplicación"
          div do
            link_to "Manual de uso de datos de carácter personal", "/pdf/PODEMOS_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PODEMOS_v.2014.09.10.pdf", target: "_blank"
          end
          div "Documento de seguridad"
          div "Funciones y obligaciones del personal"
          div "Relación de administradores"
          div "Relación de usuarios autorizados"
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
          panel "Cambios" do 
            table_for PaperTrail::Version.order('id desc').limit(20) do # Use PaperTrail::Version if this throws an error
              column "Item" do |v| link_to v.item, v.item.admin_permalink end
              # column ("Item") { |v| link_to v.item, [:admin, v.item] } # Uncomment to display as link
              column ("Type") { |v| v.item_type.underscore.humanize }
              column ("Modified at") { |v| v.created_at.to_s :long }
            end
          end
        end
      end
    end
  end
end
