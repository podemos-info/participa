ActiveAdmin.register UserVerification do
  menu :parent => "Users"
  config.sort_order = 'created_at_asc'
  permit_params do
    params = [:user_id, :processed_at, :publisher_id, :front_vatid, :back_vatid, :wants_card]
    params.push :status, :comment, if: proc {current_user.is_admin?}
    params
  end

  actions :index, :show, :edit, :update

  scope "Todas", :all
  scope "Pendientes", :pending, default: true
  scope "Aceptadas", :accepted, if: proc {current_user.is_admin?}
  scope "Aceptadas por Email", :accepted_by_email, if: proc {current_user.is_admin?}
  scope "Con Problemas", :issues, if: proc {current_user.is_admin?}
  scope "Rechazadas", :rejected, if: proc {current_user.is_admin?}

  filter :status , label: "Estado"
  filter :user_document_vatid, as: :string, label: "Número de documento"
  filter :user_first_name, as: :string, label: "Nombre"
  filter :user_last_name, as: :string, label: "Apellidos"

  index do |verification|
    column "persona" do |verification|
      verification.user.full_name
    end

    column "fecha petición", :created_at

    column "estado" do |verification|
      case UserVerification.statuses[verification.status]
        when UserVerification.statuses[:pending]
          status_tag("Pendiente", :warning)
        when UserVerification.statuses[:accepted]
          status_tag("Verificado", :ok)
        when UserVerification.statuses[:accepted_by_email]
          status_tag("Verificado por Email", :ok)
        when UserVerification.statuses[:issues]
          status_tag("con Problemas", :important)
        when UserVerification.statuses[:rejected]
          status_tag("Rechazado", :error)
      end
    end

    #column "numDNI" do |verification|
    #  verification.user.document_vatid
    #end
    #column "DNI" do |verification|
    #  image_tag images_user_verification_path(id:verification.id,attachment:"front_vatid", filename:verification.front_vatid_file_name, size: "150x150")
    #end

    actions defaults: false do |verification|
      link_to t("procesar"), edit_admin_user_verification_path(verification.id)
    end
  end

  show do |verification|
    columns do
      column do
        render partial: "personal_data"
      end

      column class: "column attachments" do
        [:front, :back].each do |attachment|
          div class: "attachment" do
            a class: "preview", target: "_blank", href: view_image_admin_user_verification_path(user_verification, attachment: attachment, size: :original) do
              image_tag view_image_admin_user_verification_path(user_verification, attachment: attachment, size: :thumb)
            end
            div class: "rotate" do
              span "ROTAR"
              [0, 90, 180, 270].reverse.each do |degrees|
                a class: "degrees-#{degrees}", href: rotate_admin_user_verification_path(user_verification, attachment: attachment, degrees: degrees), "data-method" => :patch do
                  fa_icon "id-card-o"
                end
              end
            end
          end
        end
      end
    end
  end

  form title: "Verificar Identidad", decorate: true do |f|
    columns do
      column do
        render partial: "personal_data"
        panel "verificar" do
          f.inputs :class => "remove-padding-top" do
            f.input :status, :label => "Estado", :as => :radio, :collection => current_user.is_admin? ? {
                "Pendiente": UserVerification.statuses.keys[ UserVerification.statuses[:pending]],
                "Aceptado": UserVerification.statuses.keys[ UserVerification.statuses[:accepted]],
                "Con problemas": UserVerification.statuses.keys[ UserVerification.statuses[:issues]],
                "Rechazado": UserVerification.statuses.keys[ UserVerification.statuses[:rejected]]} : {
                "Pendiente": UserVerification.statuses.keys[ UserVerification.statuses[:pending]],
                "Aceptado": UserVerification.statuses.keys[ UserVerification.statuses[:accepted]],
                "Con problemas": UserVerification.statuses.keys[ UserVerification.statuses[:issues]]}
            f.input :comment, :label => "Comentarios", as: :text, :input_html => {:rows => 2}
          end
          f.actions
        end
      end
      column class: "column attachments" do
        more_pending = resource.user.user_verifications
        if more_pending.any? { |verification| verification!=resource }
          div class: "flash flash_error" do
            "ATENCIÓN: Este usuario ha enviado varias solicitudes de verificación. Por favor, compruébalas antes de continuar."
          end
          table_for more_pending do
            column "fecha creación", :created_at
            column "estado" do |verification|
              t("podemos.user_verification.status.#{verification.status}")
            end
            column do |verification|
              if verification.id == resource.id
                span "registro actual"
              else
                link_to "procesar", edit_admin_user_verification_path(verification.id)
              end
            end
          end
        end

        [:front, :back].each do |attachment|
          div class: "attachment" do
            a class: "preview", target: "_blank", href: view_image_admin_user_verification_path(user_verification, attachment: attachment, size: :original) do
              image_tag view_image_admin_user_verification_path(user_verification, attachment: attachment, size: :thumb)
            end
            div class: "rotate" do
              span "ROTAR"
              [0, 90, 180, 270].reverse.each do |degrees|
                a class: "degrees-#{degrees}", href: rotate_admin_user_verification_path(user_verification, attachment: attachment, degrees: degrees), "data-method" => :patch do
                  fa_icon "id-card-o"
                end
              end
            end
          end
        end
      end
    end
  end

  member_action :rotate, method: :patch do
    verification = UserVerification.find(params[:id])
    attachment = "#{params[:attachment]}_vatid"
    degrees = -params[:degrees].to_i
    verification.rotate[attachment] = degrees
    verification.send(attachment).reprocess!
    redirect_to :back
  end

  member_action :view_image do
    verification = UserVerification.find(params[:id])
    attachment = "#{params[:attachment]}_vatid"
    size = params[:size].to_sym
    send_file verification.send(attachment).path(size), disposition: 'inline'
  end

  controller do
    def update
      if current_user.verifier? or current_user.is_admin?
        super do |format|
          verification = UserVerification.find(permitted_params[:id])
          case UserVerification.statuses[verification.status]
            when UserVerification.statuses[:accepted]
              if current_user.is_admin? or current_user.verfier?
                u = User.find( verification.user_id )
                u.verified = true
                u.banned = false
                u.save
                UserVerificationMailer.on_accepted(verification.user_id).deliver_now
              end
            when UserVerification.statuses[:rejected]
              UserVerificationMailer.on_rejected(verification.user_id).deliver_now if current_user.is_admin?
          end
        end
      end
    end
  end
end

