ActiveAdmin.register User do
  config.per_page = 50

  scope_to User, association_method: :with_deleted

  scope :created, default: true
  scope :confirmed
  scope :deleted
  scope :unconfirmed_mail
  scope :unconfirmed_phone
  scope :legacy_password
  scope :confirmed_mail
  scope :confirmed_phone
  scope :signed_in
  scope :has_collaboration
  scope :has_collaboration_credit_card
  scope :has_collaboration_bank_national
  scope :has_collaboration_bank_international
  scope :participation_team
  scope :has_circle
  scope :banned
  scope :verified
  scope :not_verified

  permit_params :email, :phone, :unconfirmed_phone, :password, :password_confirmation, :first_name, :last_name, :gender, :document_type, :document_vatid, :born_at, :address, :town, :postal_code, :province, :country, :vote_province, :vote_town, :wants_newsletter, :vote_district, :circle

  index download_links: -> { Rails.env.production? && current_user.is_admin? && current_user.superadmin? } do
    selectable_column
    id_column
    column :full_name
    column "Lugar de participación" do |user|
      "#{user.vote_town_name} (#{user.vote_province_name})"
    end
    column :email
    column :phone
    column :ips do |user|
      "#{user.current_sign_in_ip}<br/>#{user.last_sign_in_ip}".html_safe
    end
    column :created_at
    column :validations do |user|
      status_tag("Verificado", :ok) + br if user.verified?
      status_tag("Baneado", :error) + br if user.banned?
      user.confirmed_at? ? status_tag("Email", :ok) : status_tag("Email", :error)
      user.sms_confirmed_at? ? status_tag("Tel", :ok) : status_tag("Tel", :error)
      user.valid? ? status_tag("Val", :ok) : status_tag("Val", :error)
      user.deleted? ? status_tag("Borrado", :error) : ""
    end
    actions
  end

  show do
    authorize! :admin, user
    attributes_table do
      row :id
      row :status do
        status_tag("Verificado", :ok) if user.verified?
        status_tag("Baneado", :error) if user.banned?
        user.deleted? ? status_tag("¡Atención! este usuario está borrado, no podrá iniciar sesión", :error) : ""
        if user.confirmed_at?
          status_tag("El usuario ha confirmado por email", :ok)
        else
          status_tag("El usuario NO ha confirmado por email", :error)
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
        if user.phone?
          span link_to("Ver en panel de Elementos Enviados de Esendex (confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{user.phone.sub(/^00/,'')}")
        end
        if user.unconfirmed_phone?
          span link_to("Ver en panel de Elementos Enviados de Esendex (no confirmado)", "https://www.esendex.com/echo/a/EX0145806/Sent/Messages?FilterRecipientValue=#{user.unconfirmed_phone.sub(/^00/,'')}")
        end
      end
      row :validations_status do
        if user.valid?
          status_tag("El usuario supera todas las validaciones", :ok)
        else
          status_tag("El usuario no supera alguna validación", :error)
          ul
            user.errors.full_messages.each do |mes|
              li mes
            end
        end
      end
      row :full_name
      row :first_name
      row :last_name
      row :gender do
        user.gender_name
      end
      row :document_type do
        user.document_type_name
      end
      row :document_vatid
      row :born_at
      row :email
      row :vote_town_name
      row :address
      row :postal_code

      row :country do
        user.country_name
      end
      row :autonomy do
        user.autonomy_name
      end
      row :province do
        user.province_name
      end
      row :town do
        user.town_name
      end
      row :in_spanish_island? do
        if user.in_spanish_island?
          user.island_name
        else
          status_tag("NO", :error)
        end
      end
      row :vote_place do
        district = user.vote_district ? " / distrito #{user.vote_district}" : ""
        "#{user.vote_autonomy_name} / #{user.vote_province_name} / #{user.vote_town_name}#{district}"
      end
      row :vote_in_spanish_island? do
        if user.vote_in_spanish_island?
          user.vote_island_name
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
      row :participation_team_at
    end

    panel "Votos" do
      if user.votes.any?
        table_for user.votes do
          column :election
          column :voter_id
          column :created_at
        end
      else
        "No hay votos asociados a este usuario."
      end
    end

    if !user.participation_team_at.nil?

      panel "Equipos de Acción Participativa" do
        if user.participation_team.any?
          table_for user.participation_team do
            column :name
            column :active
          end
        else
          "El usuario no está inscrito en equipos específicos."
        end
      end
    end
    active_admin_comments
  end

  sidebar "Buscar personas en Participa", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render("admin/users/process_search_persons")
  end

  filter :email
  filter :gender, as: :select, collection: User::GENDER.invert
  filter :document_vatid
  filter :document_vatid_in, as: :string, label: "Lista de DNI o NIE"
  filter :id_in, as: :string, label: "Lista de IDs"
  filter :email_in, as: :string, label: "Lista de emails"
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
  filter :vote_autonomy_in, as: :select, collection: Podemos::GeoExtra::AUTONOMIES.values.uniq.map(&:reverse), label: "Vote autonomy"
  filter :vote_province_in, as: :select, collection: Carmen::Country.coded("ES").subregions.map{|x|[x.name, "p_#{(x.index).to_s.rjust(2,"0")}"]}, label: "Vote province"
  filter :vote_island_in, as: :select, collection: Podemos::GeoExtra::ISLANDS.values.uniq.map(&:reverse), label: "Vote island"
  filter :vote_town
  filter :current_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_at
  filter :last_sign_in_ip
  filter :has_legacy_password
  filter :created_at
  filter :confirmed_at
  filter :sms_confirmed_at
  filter :sign_in_count
  filter :wants_participation
  filter :participation_team_id, as: :select, collection: ParticipationTeam.all
  filter :votes_election_id, as: :select, collection: Election.all

  form partial: "form"

  csv do
    column :id
    column :first_name
    column :last_name
    column :gender_name
    column :document_vatid
    column :born_at
    column :email
    column :phone
    column :country
    column :country_name
    column :province
    column :province_name
    column :town
    column :town_name
    column :address
    column :postal_code
    column("vote_autonomy") { |u| u.vote_autonomy_name }
    column :vote_town_name
    column :vote_town
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :circle
    column :created_at
    column :deleted_at
  end

  action_item(:restore, only: :show) do
    link_to('Recuperar usuario borrado', recover_admin_user_path(user), method: :post, data: { confirm: "¿Estas segura de querer recuperar este usuario?" }) if user.deleted?
  end

  action_item(:ban, only: :show) do
    if can? :ban, User
      if user.banned?
        link_to('Desbanear usuario', ban_admin_user_path(user), method: :delete)
      else
        link_to('Banear usuario', ban_admin_user_path(user), method: :post, data: { confirm: "¿Estas segura de querer banear a este usuario?" })
      end
    end
  end

  action_item(:verify, only: :show) do
    if user.not_verified?
      link_to('Verificar usuario', verify_admin_user_path(user), method: :post, data: { confirm: "¿Estas segura de querer verificar a este usuario?" })
    end
  end

  batch_action :ban, if: proc{ can? :ban, User } do |ids|
    User.ban_users(ids, true)
    redirect_to collection_path, alert: "Los usuarios han sido baneados."
  end

  collection_action :process_search_persons, :method => :post do
    #file_input = CSV.read(params["process_search_persons"]["file"].tempfile)
    file_input = params["process_search_persons"]["file"].original_filename
    file_output = file_input[0..-5]+"_Cout.csv"

    i=0
    query = "lower(document_vatid)= ?"
    non_user_query = "lower(non_user_document_vatid)= ?"
    directory= "/home/capistrano/borrame/"
    buscados={}
    encode="windows-1252" #"UTF-8"
    sep=";" #","

    #Step 0 read the persons to search
    CSV.foreach(params["process_search_persons"]["file"].tempfile, {:encoding=>encode, :headers=>true, :col_sep=>sep}) do |row|
      buscados[row.fields[0].to_i]=Hash[row.headers[0..-1].zip(row.fields[0..-1].map!{|x| x.downcase.strip if x.respond_to?("strip")})]
      i+=1
    end

    #Step 1 search persons by DNI in Users
    encontrados={}
    buscados.each {|r| User.with_deleted.where(query, r[1]["dni"]).each {|f| encontrados[r[0].to_i]={:fileid=>r[0],:file_name=>r[1]["name"],:file_last_name=>r[1]["surname"],:dni=>f.document_vatid,:name=>f.first_name,:last_name=>f.last_name,:email=>f.email,:phone=>f.phone,:address=>f.address,:cp=>f.postal_code,:vote_town=>f.vote_town_name,:province=>f.province_name,:country=>f.country_name,:type=>1,:is_user=>"SI"}}}
    #CSV.open( "ficheros/#{file_output}", 'w' ) {|writer| encontrados.each {|u| writer << [u[1][:fileid],u[1][:file_name],u[1][:file_last_name],u[1][:file_dni],u[1][:name],u[1][:last_name],u[1][:email],u[1][:phone],u[1][:address],u[1][:cp],u[1][:vote_town],u[1][:province],u[1][:country]]}}
    buscados1b= buscados.clone
    buscados1b.delete_if{|key, value| !encontrados[key].nil?}

    #Step 1B search persons non_users in collaborations
    # where("non_user_document_vatid is not null")
    buscados1b.each do |r|
      Collaboration.non_user.where(non_user_query, r[1]["dni"]).each do |f|
        non_user = f.parse_non_user
        encontrados[r[0].to_i]={:fileid=>r[0],:file_name=>r[1]["name"],:file_last_name=>r[1]["surname"],:dni=>non_user.document_vatid,:name=>non_user.full_name,:last_name=>"",:email=>non_user.email,:phone=>non_user.phone,:address=>non_user.address,:cp=>non_user.postal_code,:vote_town=>non_user.town_name,:province=>non_user.province,:country=>non_user.country,:type=>1,:is_user=>"NO"}
      end
    end

    buscados2= buscados1b.clone
    buscados2.delete_if{|key, value| !encontrados[key].nil?}
    #print "\n#{buscados2.count} casos para el paso 2"
    #step 2 with the not found records in previous step, search by email
    query = "email= ?"
    buscados2.each {|r| User.with_deleted.where(query, r[1]["email"]).each {|f| encontrados[r[0].to_i]={:fileid=>r[0],:file_name=>r[1]["name"],:file_last_name=>r[1]["surname"],:dni=>f.document_vatid,:name=>f.first_name,:last_name=>f.last_name,:email=>f.email,:phone=>f.phone,:address=>f.address,:cp=>f.postal_code,:vote_town=>f.vote_town_name,:province=>f.province_name,:country=>f.country_name,:type=>2,:is_user=>"SI"}}}
    #CSV.open( "ficheros/#{file_output}", 'a' ) {|writer| encontrados.each {|u| writer << [u[1][:fileid],u[1][:file_name],u[1][:file_last_name],u[1][:file_dni],u[1][:name],u[1][:last_name],u[1][:email],u[1][:phone],u[1][:address],u[1][:cp],u[1][:vote_town],u[1][:province],u[1][:country]]}}
    buscados3= buscados2.clone
    buscados3.delete_if{|key, value| !encontrados[key].nil?}
    #print "\n#{buscados3.count} casos para el paso 3"

    # step 3 search by name and lastname but this step don't asure correctnes in data

    query_name_and_last_name = "lower(first_name)= ? and lower(last_name)=?"
    query_full_name = "lower(CONCAT_WS(' ', first_name, last_name))= ?"

    buscados3.each {|r|
      name=r[1]["name"] || ""
      surname = r[1]["surname"] || ""
      full_name = r[1]["full_name"] || ""
      params=[]
      if (name != "" or surname != "")
        query = query_name_and_last_name
        params = [name.downcase.strip,surname.downcase.strip]
      elsif full_name != ""
        query = query_full_name
        params = full_name.downcase.strip
      else
        query = nil
      end
      User.with_deleted.where(query, *params).each {|f| encontrados[r[0].to_i]={:fileid=>r[0],:file_name=>r[1]["name"],:file_last_name=>r[1]["surname"],:dni=>f.document_vatid,:name=>f.first_name,:last_name=>f.last_name,:email=>f.email,:phone=>f.phone,:address=>f.address,:cp=>f.postal_code,:vote_town=>f.vote_town_name,:province=>f.province_name,:country=>f.country_name,:type=>3,:is_user=>"SI"}} if query
    }
    #CSV.open( "ficheros/#{file_output}", 'a' ) {|writer| encontrados.each {|u| writer << [u[1][:fileid],u[1][:file_name],u[1][:file_last_name],u[1][:file_dni],u[1][:name],u[1][:last_name],u[1][:email],u[1][:phone],u[1][:address],u[1][:cp],u[1][:vote_town],u[1][:province],u[1][:country]]}}
    no_encontrados= buscados.clone
    no_encontrados.delete_if{|key, value| !encontrados[key].nil?}

    # step 4 add the not found records correctly identified

    no_encontrados.each{|r| encontrados[r[0].to_i]={:fileid=>r[0],:file_name=>r[1]["name"],:file_last_name=>r[1]["surname"],:dni=>"",:name=>"",:last_name=>"",:email=>"",:phone=>"",:address=>"",:cp=>"",:vote_town=>"",:province=>"",:country=>"",:type=>4,:is_user=>""}}

    # step 5 sort and write all records and tipologies

    csv=CSV.generate( encoding: 'UTF-8' ) do|writer|
      writer << ["APELLIDOS","NOMBRE","NOMBRE COMPLETO","DNI","EMAIL","DIRECCION","COD POSTAL", "MUNICIPIO","PROVINCIA","PAIS","TELEFONO","TIPO","ES_USUARIO" "ID"]
      encontrados.sort_by{|id| id}.each {|u| writer << [u[1][:last_name],u[1][:name],"#{u[1][:last_name]} #{u[1][:name]}",u[1][:dni],u[1][:email],u[1][:address],u[1][:cp],u[1][:vote_town],u[1][:province],u[1][:country],u[1][:phone],u[1][:type],u[1][:is_user],u[1][:fileid]]}
    end
    send_data csv.encode('UTF-8'), :type=> 'text/csv; charset=utf-8; header=present', :disposition=> "inline", :filename=>"#{file_output}"
  end

  member_action :ban, if: proc{ can? :ban, User }, :method => [:post, :delete] do
    User.ban_users([ params[:id] ], request.post?)
    flash[:notice] = "El usuario ha sido modificado"
    redirect_to action: :show
  end

  member_action :verify, :method => [:post] do
    u = User.find( params[:id] )
    u.verified = true
    u.banned = false
    u.save
    flash[:notice] = "El usuario ha sido modificado"
    redirect_to action: :show
  end

  action_item(:paper_authority, only: :show) do
    if user.paper_authority?
      link_to('Desmarcar como autoridad', paper_authority_admin_user_path(user), method: :delete, data: { confirm: "¿Quieres que esta persona deje de ser autoridad en votaciones presenciales?" })
    else
      link_to('Marcar como autoridad', paper_authority_admin_user_path(user), method: :post, data: { confirm: "¿Quieres que esta persona pueda ser autoridad en votaciones presenciales?" })
    end
  end

  member_action :paper_authority, method: %w[post delete] do
    u = User.find(params[:id])
    u.paper_authority = request.post?
    u.save
    flash[:notice] = "El usuario ya #{'no' if request.delete?} puede ejercer de autoridad en votaciones presenciales"
    redirect_to action: :show
  end

  action_item(:impulsa_author, only: :show) do
    if user.impulsa_author?
      link_to('Quitar autor Impulsa', impulsa_author_admin_user_path(user), method: :delete, data: { confirm: "¿Estas segura de que este usuario ya no puede crear proyectos especiales en Impulsa?" })
    else
      link_to('Autor Impulsa', impulsa_author_admin_user_path(user), method: :post, data: { confirm: "¿Estas segura de que este usuario puede crear proyectos especiales en Impulsa?" })
    end
  end

  member_action :impulsa_author, :method => [:post, :delete] do
    u = User.find( params[:id] )
    u.impulsa_author = request.post?
    u.save
    flash[:notice] = "El usuario ya #{"no" if request.delete?} puede crear proyectos especiales en Impulsa"
    redirect_to action: :show
  end

  member_action :recover, :method => :post do
    user = User.with_deleted.find(params[:id])
    user.restore
    flash[:notice] = "Ya se ha recuperado el usuario"
    redirect_to action: :show
  end

  sidebar :collaborations, only: :show do
    if user.collaboration
      attributes_table_for user.collaboration do
        row :link do
          link_to "Ver ficha", admin_collaboration_path(user.collaboration)
        end
        row :amount do |collaboration|
          number_to_currency ( collaboration.amount / 100.0 )
        end
        row :frequency_name
        row :payment_type_name
        row :created_at
      end
    else
      "No hay colaboraciones asociadas a este usuario."
    end
  end

  sidebar :versionate, :partial => "admin/version", :only => :show

  sidebar "Control de IPs", only: :show do
    ips = [user.last_sign_in_ip, user.current_sign_in_ip]
    t = User.arel_table
    users = User.where.not(id:user.id).where(t[:last_sign_in_ip].in(ips).or(t[:current_sign_in_ip].in(ips)))
    table_for users.first(25) do
      column "Usuarios con la misma IP: #{users.count}" do |u|
        span link_to(u.full_name, admin_user_path(u))
        br
        span u.document_vatid
        span " - #{u.phone}" if u.phone
        br
        span b u.created_at.strftime "%Y-%m-%d %H:%M"
      end
    end
  end

  sidebar "CRUZAR DATOS", 'data-panel' => :collapsed, :only => :index, priority: 100 do
    render("admin/fill_csv_form")
  end

  collection_action :fill_csv, :method => :post do
    require 'podemos_export'
    file = params["fill_csv"]["file"]
    subaction = params["commit"]
#    csv = fill_data file.read, User.confirmed
    csv = fill_data file.read.force_encoding('utf-8'), User
    if subaction == "Descargar CSV"
      send_data csv["results"],
        type: 'text/csv; charset=utf-8; header=present',
        disposition: "attachment; filename=participa.podemos.#{Date.today.to_s}.csv"
    else
      flash[:notice] = "Usuarios procesados: #{csv['processed'].join(',')}. Total: #{csv['processed'].count}"
      redirect_to action: :index, "[q][id_in]": "#{csv['processed'].join(' ')}"
    end
  end

  controller do
    def show
      @user = User.with_deleted.find(params[:id])
      @versions = @user.versions
      @user = @user.versions[params[:version].to_i].reify if params[:version]
      show! #it seems to need this
    end

    before_filter :multi_values_filter, :only => :index
    private

    def multi_values_filter
      #params[:q][:document_vatid_cont_any] = params[:q][:document_vatid_cont_any].split unless params[:q].nil? or params[:q][:document_vatid_cont_any].nil?
      params[:q][:id_in] = params[:q][:id_in].split unless params[:q].nil? or params[:q][:id_in].nil?
      params[:q][:document_vatid_in] = params[:q][:document_vatid_in].split unless params[:q].nil? or params[:q][:document_vatid_in].nil?
      params[:q][:email_in] = params[:q][:email_in].split unless params[:q].nil? or params[:q][:email_in].nil?
    end
  end

  sidebar "Equipos de participación", only: :index, priority: 0 do
    form action: download_participation_teams_admin_users_path, method: :post do
      input :name => :authenticity_token, :type => :hidden, :value => form_authenticity_token.to_s
      div class: :filter_form_field do
        label "Fecha de inicio"
        input name: :date, type: :date, placeholder:"dd/mm/aaaa", pattern:'\d{1,2}/\d{1,2}/\d{4}'
      end
      div class: :buttons do
        input :type => :submit, value: "Descargar"
      end
    end
  end

  collection_action :download_participation_teams, :method => :post do
    if params[:date].nil? or params[:date].empty?
      date = DateTime.civil(1900,1,1)
    else
      date = DateTime.parse(params[:date])
    end

    csv = CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      csv << ["ID", "Código de identificacion", "Nombre", "País", "Comunidad Autónoma", "Municipio", "Código postal", "Teléfono", "Círculo", "Email", "Equipos"]
      User.participation_team.where("participation_team_at>?", date).each do |user|
        csv << [ user.id, "#{user.postal_code}#{user.phone}", user.first_name, user.country_name, user.autonomy_name, user.town_name, user.postal_code, user.phone, user.circle, user.email, user.participation_team.map { |team| team.name }.join(",") ]
      end
    end

    send_data csv.encode('utf-8'),
      type: 'text/tsv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.participationteams.#{Date.today.to_s}.csv"
  end

  sidebar :report, only: :index do
    form action: create_report_admin_users_path, method: :post do
      input :name => :authenticity_token, :type => :hidden, :value => form_authenticity_token.to_s
      input :name => :query, :type => :hidden, :value => Report.serialize_relation_query(users)
      div class: :filter_form_field do
        label "Titulo"
        input name: :title
      end
      label "Grupos"
      div class: :filter_form_field do
        label "Principal"
        select name: :main_group do
          option value: nil do "-- Ninguno --" end
          ReportGroup.all.each do |g|
            option value: g.id do g.title end
          end
        end
      end
      div class: :filter_form_field do
        ReportGroup.all.each do |g|
          label do
            input name: "groups[]", type: :checkbox, value: g.id
            span g.title
          end
        end
      end
      div class: :filter_form_field do
        label "Fecha de versión (lento)"
        input name: :version_at
      end
      div class: :buttons do
        input :type => :submit, value: "Crear informe"
      end
    end
  end

  collection_action :create_report, :method => :post do
    Report.create do |r|
      r.title = params[:title]
      r.query = params[:query]
      r.version_at = params[:version_at]
      r.main_group = ReportGroup.find(params[:main_group].to_i) if params[:main_group].to_i>0
      r.groups = ReportGroup.where(id: params[:groups].map {|g| g.to_i} ).to_a
    end
    flash[:notice] = "El informe ha sido generado"
    redirect_to action: :index
  end

end
