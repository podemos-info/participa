ActiveAdmin.register UserVerification do
  menu :parent => "Users"
  permit_params do
    params = [:user_id, :processed_at, :publisher_id, :front_vatid, back_vatid: :wants_card]
    params.push :result, if: proc {current_admin_user.is_admin?}
    params
  end
  #puts current_admin_user.is_admin?
  #actions :all, except: [:new, :create, :destroy]
  actions :index, :show, :edit, :update

  scope :all
  scope :pending
  scope :accepted, if: proc {current_user.is_admin?}
  scope :issues, if: proc {current_user.is_admin?}
  scope :rejected, if: proc {current_user.is_admin?}

  #index :as => :grid do |verification|
  #index :as => :grid do |verification|

  index do |verification|
    #byebug
    # TIPO DOCUMENTO
    # NÚM DE DOCUMENTO
    # NOMBRE COMPLETO
    # FECHA VERIFICACIÓN
    # PERSONA QUE HA VERIFICADO
    # RESULTADO DE LA VERIFICACIÓN
    # Y SI PUEDE SER FOTO DEL DOCUMENTO, QUE PUEDA AMPLIARSE PARA COMPROBAR


  #var_user = verification.user
    #[var_user.document_type, var_user.document_vatid]
    column "persona" do |verification|
      verification.user.full_name
    end

    column :created_at
    column :status do |verification|

      case verification.status
        when 0
          status_tag("Pendiente", :warning)
        when 1
          status_tag("Verificado", :ok)
        when 2
          status_tag("con Problemas", :important)
        when 3
          status_tag("Rechazado", :error)
      end
    end

    #column "numDNI" do |verification|
    #  verification.user.document_vatid
    #end
    #column "DNI" do |verification|
    #  image_tag images_user_verification_path(id:verification.id,attachment:"front_vatid", filename:verification.front_vatid_file_name, size: "150x150")
    #end

    #actions defaults: false do |verification|
    #  link_to t("procesar"),"user_verifications/#{verification.id}/edit", class: "member_link"
    #end
    actions defaults: true
  end

  show do |verification|
    columns do
      column do
        panel "DNI Details" do
          columns do
            column do
              span do
                image_tag images_user_verification_path(id:verification.id,attachment:"front_vatid", filename:verification.front_vatid_file_name, size: :thumb)
              end
            end
            column do
              span do
                image_tag images_user_verification_path(id:verification.id,attachment:"back_vatid", filename:verification.back_vatid_file_name, size: :thumb)
              end
            end
          end
        end
      end

      column do
        panel "User Details" do
          attributes_table_for verification.user do
            row :id
            row :status do
              status_tag("Verificado", :ok) if verification.user.verified?
              status_tag("Baneado", :error) if verification.user.banned?
              verification.user.deleted? ? status_tag("¡Atención! este usuario está borrado, no podrá iniciar sesión", :error) : ""
              if verification.user.confirmed_at?
                status_tag("El usuario ha confirmado por email", :ok)
              else
                status_tag("El usuario NO ha confirmado por email", :error)
              end
              if verification.user.sms_confirmed_at?
                status_tag("El usuario ha confirmado por SMS", :ok)
              else
                status_tag("El usuario NO ha confirmado por SMS", :error)
              end
              if verification.user.errors.any? # If there are errors, do something
                verification.user.errors.each do |attribute, message|
                  b attribute
                  span message
                end
              end
            end
            row :esendex_status do
              if verification.user.phone?
                span link_to("Ver en panel de Elementos Enviados de Esendex (confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{verification.user.phone.sub(/^00/,'')}")
              end
              if verification.user.unconfirmed_phone?
                span link_to("Ver en panel de Elementos Enviados de Esendex (no confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{verification.user.unconfirmed_phone.sub(/^00/,'')}")
              end
            end
            row :validations_status do
              if verification.user.valid?
                status_tag("El usuario supera todas las validaciones", :ok)
              else
                status_tag("El usuario no supera alguna validación", :error)
                ul
                verification.user.errors.full_messages.each do |mes|
                  li mes
                end
              end
            end
            row :full_name
            row :first_name
            row :last_name
            row :gender do
              verification.user.gender_name
            end
            row :document_type do
              verification.user.document_type_name
            end
            row :document_vatid
            row :born_at
            row :email
            row :vote_town_name
            row :address
            row :postal_code

            row :country do
              verification.user.country_name
            end
            row :autonomy do
              verification.user.autonomy_name
            end
            row :province do
              verification.user.province_name
            end
            row :town do
              verification.user.town_name
            end
            row :in_spanish_island? do
              if verification.user.in_spanish_island?
                verification.user.island_name
              else
                status_tag("NO", :error)
              end
            end
            row :vote_place do
              district = verification.user.vote_district ? " / distrito #{verification.user.vote_district}" : ""
              "#{verification.user.vote_autonomy_name} / #{verification.user.vote_province_name} / #{verification.user.vote_town_name}#{district}"
            end
            row :vote_in_spanish_island? do
              if verification.user.vote_in_spanish_island?
                verification.user.vote_island_name
              else
                status_tag("NO", :error)
              end
            end
            row :admin
            row :circle
            row :created_at
            row :updated_at
            row :confirmation_sent_at
            row :confirmed_at
            row :unconfirmed_email
            row :has_legacy_password
            row "Teléfono móvil (confirmado)" do
              verification.user.phone
            end
            row "Teléfono móvil (sin confirmar)" do
              verification.user.unconfirmed_phone
            end
            row :sms_confirmation_token
            row :confirmation_sms_sent_at
            row :sms_confirmed_at
            #row :sms_confirmation do
            #  link_to "Ver en Esendex (proveedor SMS)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue="
            #end
            row :failed_attempts
            row :locked_at
            row :sign_in_count
            row :current_sign_in_at
            row :last_sign_in_at
            row :last_sign_in_ip
            row :current_sign_in_ip
            row :remember_created_at
            row :deleted_at
            row :participation_team_at
          end

          panel "Votos" do
            if verification.user.votes.any?
              table_for verification.user.votes do
                column :election
                column :voter_id
                column :created_at
              end
            else
              "No hay votos asociados a este usuario."
            end
          end

          if !verification.user.participation_team_at.nil?
            panel "Equipos de Acción Participativa" do
              if verification.user.participation_team.any?
                table_for verification.user.participation_team do
                  column :name
                  column :active
                end
              else
                "El usuario no está inscrito en equipos específicos."
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
          f.inputs do
            f.input :status, :as => :radio, :collection => ["Pendiente", "Aceptado", "Con problemas", "Rechazado"]
            f.input :comment, as: :text
          end
          f.actions
        end
      end
      column do
        panel "DNI Details" do
          span do
            image_tag images_user_verification_path(id:user_verification.id,attachment:"front_vatid", filename:user_verification.front_vatid_file_name, size: :thumb)
          end
          span do
            image_tag images_user_verification_path(id:user_verification.id,attachment:"back_vatid", filename:user_verification.back_vatid_file_name, size: :thumb)
          end

        end
      end
    end
  end
end


