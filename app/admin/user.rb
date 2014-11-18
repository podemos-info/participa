ActiveAdmin.register User do

  scope_to :current_user, :association_method => :users_with_deleted

  scope :created
  scope :confirmed
  scope :deleted
  scope :unconfirmed_mail
  scope :unconfirmed_phone
  scope :legacy_password
  scope :confirmed_mail
  scope :confirmed_phone
  scope :signed_in

  permit_params :email, :password, :password_confirmation, :first_name, :last_name, :document_type, :document_vatid, :born_at, :address, :town, :postal_code, :province, :country, :wants_newsletter

  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :status do |user|
      user.deleted? ? status_tag("Borrado", :error) : ""
    end
    column :validations do |user|
      user.confirmed_at? ? status_tag("Email", :ok) : status_tag("Email", :error)
      user.sms_confirmed_at? ? status_tag("Tel", :ok) : status_tag("Tel", :error)
    end
    actions
  end

  show do 
    attributes_table do
      row :status do 
        user.deleted? ? status_tag("¡Atención! este usuario está borrado, no podrá iniciar sesión", :error) : ""
        if user.confirmed_at? 
          status_tag("El usuario ha confirmado por correo electrónico", :ok)
        else
          status_tag("El usuario NO ha confirmado por correo electrónico", :error)
        end
        if user.sms_confirmed_at? 
          status_tag("El usuario ha confirmado por SMS", :ok)
        else
          status_tag("El usuario NO ha confirmado por SMS", :error)
        end
        if user.errors.any? # If there are errors, do something
          user.errors.each do |attribute, message|
            b attribute
            span message
          end
        end
      end
      row :esendex_status do 
        link_to "Ver en panel de Elementos Enviados de Esendex (no confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{user.unconfirmed_phone.sub(/^00/,'')}" if user.unconfirmed_phone
        link_to "Ver en panel de Elementos Enviados de Esendex (confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{user.phone.sub(/^00/,'')}" if user.phone
      end
      row :full_name
      row :first_name
      row :last_name
      row :document_type do 
        user.document_type_name
      end
      row :document_vatid
      row :born_at
      row :email
      row :address
      row :postal_code
      row :province do
        user.province_name
      end
      row :country do
        user.country_name
      end
      row :town do
        user.town_name
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
        user.phone
      end
      row "Teléfono móvil (sin confirmar)" do 
        user.unconfirmed_phone
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
    end
    active_admin_comments
  end

  filter :email
  filter :document_vatid
  filter :admin
  filter :first_name
  filter :last_name
  filter :phone
  filter :born_at
  filter :created_at
  filter :address
  filter :town
  filter :postal_code
  filter :province
  filter :country
  filter :circle
  filter :last_sign_in_at
  filter :last_sign_in_ip
  filter :has_legacy_password
  filter :created_at
  filter :confirmed_at
  filter :sms_confirmed_at
  filter :sign_in_count

  form partial: "form"

  #collection_action :download_newsletter_csv, :method => :get do
  #  users = User.wants_newsletter
  #  csv = CSV.generate(encoding: 'utf-8') do |csv|
  #    users.each { |user| csv << [ user.email ] }
  #  end
  #  send_data csv.encode('utf-8'), 
  #    type: 'text/csv; charset=utf-8; header=present', 
  #    disposition: "attachment; filename=podemos.newsletter.#{Date.today.to_s}.csv"
  #end

  csv do
    column :id
    column("Nombre") { |u| u.full_name }
    column :email
  end

  action_item :only => :show do
    link_to('Recuperar usuario borrado', recover_admin_user_path(user), method: :post, data: { confirm: "¿Estas segura de querer recuperar este usuario?" }) if user.deleted?
  end

  member_action :recover, :method => :post do
    user = User.with_deleted.find(params[:id])
    user.restore
    flash[:notice] = "Ya se ha recuperado el usuario"
    redirect_to action: :show
  end

  sidebar :votes, only: :show do
    if user.votes.any?
      table_for user.votes
    else
      "No hay votos asociados a este usuario."
    end
  end

  sidebar :collaborations, only: :show do
    if user.collaboration
      table_for user.collaboration
    else
      "No hay colaboraciones asociadas a este usuario."
    end
  end

  # FIXME: bug, only 2 mails
  #  action_item only: :index do
  #    link_to('Descargar correos para Newsletter (CSV)', params.merge(:action => :download_newsletter_csv))
  #  end 

end
