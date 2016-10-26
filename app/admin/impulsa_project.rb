ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params do
    ps = [:review, :name, :impulsa_edition_category_id]
    all_fields = resource.wizard_step_admin_params

    if params[:review]
      all_fields.concat(all_fields.pop.keys) if all_fields.last.is_a?(Hash)  # last param could be a hash for multivalue fields  
      ps.concat(all_fields.map {|param| "_rvw"+param[4..-1]}) if resource.reviewable?    # add review fields
    else
      ps.concat(all_fields)
    end
    ps
  end

  filter :impulsa_edition_category, as: :select, collection: -> { parent.impulsa_edition_categories}
  filter :name
  filter :user_id
  filter :id_in, as: :string, label: "Lista de IDs de proyectos", required: false
  filter :user_email_contains

  index download_links: -> { can?(:admin, ImpulsaProject) } do
    selectable_column
    column :id
    column :name do |impulsa_project|
      link_to impulsa_project.name, admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
    end
    column :user
    column :impulsa_edition_category
    
    #column :updated_at
    column :state do |impulsa_project|
      div impulsa_project.state
      if impulsa_project.wizard_valid?
        status_tag("OK", :ok)
      else
        status_tag("#{impulsa_project.errors.keys.length} errores", :error)
      end
    end
    column :votes
    actions
  end

  action_item(:spam, only: :show ) do
    link_to('Marcar como Spam', spam_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project), method: :post, data: { confirm: "¿Estas segura de querer marcar este proyecto como Spam?" }) if !impulsa_project.spam?
  end

  member_action :spam, :method => :post do
    p = ImpulsaProject.find( params[:id] )
    p.mark_as_spam
    p.save
    flash[:notice] = "El proyecto ha sido marcado como spam."
    redirect_to action: :index
  end

  sidebar "Subir resultados de votación", 'data-panel' => :collapsed, :only => :index, priority: 1 do  
    render("admin/upload_vote_results_form")
  end

  show do
    panel t("podemos.impulsa.admin_section") do
      attributes_table_for impulsa_project do
        row :edition do 
          link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition))
        end
        row :category do
          link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(impulsa_project.impulsa_edition, resource.impulsa_edition_category))
        end
        row :user do
          attributes_table_for impulsa_project.user do
            row :status do
                impulsa_project.user.deleted? ? status_tag("BORRADO", :error) : ""
            end
            row :full_name do
              if can?(:read, impulsa_project.user)
                link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user))
              else
                impulsa_project.user.full_name
              end
            end
            row :document_type do
              impulsa_project.user.document_type_name
            end
            row :phone
            row :email
            row :country do
              impulsa_project.user.country_name
            end
            row :autonomy do
              impulsa_project.user.vote_autonomy_name
            end
            row :province do
              impulsa_project.user.vote_province_name
            end
            row :town do
              impulsa_project.user.vote_town_name
            end
            row :address
            row :postal_code
            row :vote_place do
              district = impulsa_project.user.vote_district ? " / distrito #{impulsa_project.user.vote_district}" : ""
              "#{impulsa_project.user.vote_autonomy_name} / #{impulsa_project.user.vote_province_name} / #{impulsa_project.user.vote_town_name}#{district}"
            end
          end if impulsa_project.user
        end
        row :state
        row :created_at
        row :updated_at
      end
    end

    form method: :post do
      input type: :hidden, name: :_method, value: :patch
      input type: :hidden, name: :review, value: true
      input type: :hidden, name: :authenticity_token, value: form_authenticity_token
      impulsa_project.wizard.map do |sname, step|
        panel step[:title] do
          step[:groups].each do |gname, group|
            next if !impulsa_project.wizard_eval_condition(group)
            h3 group[:title] if group[:title]
            attributes_table_for impulsa_project do
              group[:fields].each do |fname, field|
                next if field[:type]=="boolean" && field[:format] == "accept"
                value = impulsa_project.wizard_values["#{gname}.#{fname}"]
                row field[:title] do
                  case field[:type]
                  when "select"
                    div field[:collection][value]
                  when "check_boxes"
                    div (value || []).map {|i| field[:collection][i] } .join(", ")
                  when "file"
                    div value
                  else
                    div value
                  end
                end
                row "revisión", class: "review" do
                  textarea(impulsa_project.wizard_review["#{gname}.#{fname}"], id: "impulsa_project__rvw_#{gname}__#{fname}", name: "impulsa_project[_rvw_#{gname}__#{fname}]", rows: 2) 
                end if impulsa_project.reviewable?
              end
            end
          end
        end
      end
      fieldset class: :actions do
        ol do 
          li class: "action input_action ", id: "impulsa_project_submit_action" do
            input type: :submit, value: "Marcar como revisado"
          end
        end
      end if impulsa_project.reviewable?

    end
    active_admin_comments
  end

  form do |f|
    f.inputs t("podemos.impulsa.admin_section") do
      li do
        label "Edition"
        div class: :readonly do link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition)) end
      end if impulsa_project.impulsa_edition
      if impulsa_project.impulsa_edition_category
        f.input :impulsa_edition_category
        span do link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(resource.impulsa_edition, resource.impulsa_edition_category)) end
      else
        f.input :impulsa_edition_category
      end
      if impulsa_project.user
        f.input :user_id, as: :number
        span do link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user)) end
      else
        f.input :user_id, as: :number
      end
      li do
        label "Estado"
        div class: :readonly do impulsa_project.state end
      end
      f.input :name
      f.input :votes
    end

    impulsa_project.wizard.map do |sname, step|
      f.inputs step[:title] do
        step[:groups].each do |gname, group|
          next if !impulsa_project.wizard_eval_condition(group)
          li do h3 group[:title] if group[:title] end
          group[:fields].each do |fname, field|
            field_name = :"_wiz_#{gname}__#{fname}"
            value = impulsa_project.send(field_name)
            if field[:type].in? ["select", "check_boxes"]
              f.input field_name, label: field[:title], as: field[:type], collection: field[:collection].to_a.map(&:reverse)
            else
              f.input field_name, label: field[:title], as: field[:type]
            end
          end
        end
      end
    end

    if impulsa_project.reviewable?
      f.inputs "Revisión del proyecto" do
        li do
          "Al guardar el proyecto cambiará de estado: si hay comentarios asociados a algún campo pasar al estado 'Correcciones' 
          para que sea revisado por el usuario; en caso contrario pasará al estado 'Validar'. En cualquier caso, se enviará un correo al usuario
          para informarle del progreso de su proyecto, por lo que es recomendable revisar el formulario antes de enviarlo." 
        end
      end
    elsif impulsa_project.validable?
      f.inputs "Validación del proyecto" do
        if impulsa_project.evaluator1
          li do "Validación por #{impulsa_project.evaluator1.full_name}" end
          li do impulsa_project.evaluator1_invalid_reasons end
          li do link_to(impulsa_project.evaluator1_analysis, impulsa_project.evaluator1_analysis.url) end if impulsa_project.evaluator1_analysis.exists?
        end

        if impulsa_project.evaluator1 != current_active_admin_user
          li do
            if impulsa_project.evaluator1.nil?
              "Al rellenar estos campos se almacenará su análisis del proyecto para que sea complementado con el de otro evaluador.
              Para marcar el proyecto como validado basta con dejar el campo 'Razones de invalidación' vacío."
            else
              "Al rellenar estos campos se almacenará su análisis del proyecto. Para marcar el proyecto como validado basta con 
              dejar el campo 'Razones de invalidación' vacío. Dado que otro evaluador ya ha analizado el proyecto, este cambiará de
              estado según el resultado de ambas evaluaciones: pasará a 'Validado' si ambos han aprobado el proyecto, a 'Invalidado'
              si ambos han rechazado el proyecto y a 'Disenso' si no hay acuerdo entre ambas opiniones. Salvo en el último caso, se
              enviará un correo al usuario para indicar el resultado del proceso y las razones de invalidación, si hubieran, 
              por lo que es importante revisar el formulario antes de enviarlo y asegurarse que las razones de invalidación de ambos
              evaluadores no son contradictorias para no confundir al usuario." 
            end
          end
          f.input :invalid_reasons, as: :text, label: "Razones de invalidación"
          f.input :evaluator_analysis, as: :file
        end
      end
    elsif impulsa_project.dissent?
      f.inputs "Validación del proyecto" do
        f.input :evaluator1_invalid_reasons, as: :text, label: "Razones de invalidación del evaluador 1"
        f.input :evaluator2_invalid_reasons, as: :text, label: "Razones de invalidación del evaluador 2"
      end
    end
    f.actions
  end

  collection_action :upload_vote_results, :method => :post do
    require "json"
    procesados = []
    no_id_projects = []
    winners = []
    file = params["upload_vote_results"]["file"]
    question_id = params["upload_vote_results"]["question_id"].to_i
    json = JSON.parse(file.read.force_encoding('utf-8'))
    json = json["questions"][question_id]["answers"]
    json.each do |answer|
      id_proyecto = 0
      answer["urls"].each do |url|
        id_proyecto_aux = url["url"].gsub('https://participa.podemos.info/impulsa/proyecto/','').to_i
        id_proyecto = id_proyecto_aux if id_proyecto_aux > 0
      end
      votes = answer["total_count"]
      votes = (votes * 10000 + 90000000).round if votes.is_a? Float
      proyecto = ImpulsaProject.find_by_id(id_proyecto)
      if proyecto.nil?
        no_id_projects << id_proyecto
      else
        proyecto.votes = votes
        if !answer["winner_position"].nil?
          proyecto.mark_as_winner
          winners << id_proyecto
        end
        proyecto.save
      end
      procesados << id_proyecto
    end

    flash[:notice] = "Projectos procesados: #{procesados.join(',')}. Total: #{procesados.count}"
    flash[:error] = "Projectos no encontrados: #{no_id_projects.join(',')}. Total: #{no_id_projects.count}" if no_id_projects.count > 0
    redirect_to action: :index, "[q][id_in]": "#{procesados.join(' ')}", "order":"votes_desc"
  end

  controller do
    before_filter :update_scopes, :only => :index
    before_filter :multiple_id_search, :only => :index

    def multiple_id_search
      params[:q][:id_in] = params[:q][:id_in].split unless params[:q].nil? or params[:q][:id_in].nil?
    end

    def update_scopes
      resource = active_admin_config

      '''ImpulsaProject::PROJECT_STATUS.each do |status, id|
        status_name = t("podemos.impulsa.project_status.#{status}")
        if !resource.scopes.any? { |scope| scope.name == status_name }
          resource.scopes << ActiveAdmin::Scope.new( status_name ) do |projects| projects.by_status(id) end
        end
      end'''
    end

    def update
      send_email = false
      was_dissent = resource.dissent?
      super
      if resource.reviewable? && params[:review]
        if resource.wizard_has_errors?(ignore_state: true)
          resource.mark_as_fixes
        else
          resource.mark_as_validable
        end
        flash[:notice] = "El proyecto ha sido marcado como revisado."
        send_email = true
      elsif resource.validable? && !params[:impulsa_project][:evaluator_analysis].blank?
        if resource.evaluator1.nil?
          resource.evaluator1 = current_active_admin_user
          resource.evaluator1_invalid_reasons = params[:impulsa_project][:invalid_reasons].strip
          resource.evaluator1_analysis = params[:impulsa_project][:evaluator_analysis]
          send_email = resource.save
        elsif resource.evaluator1!=current_active_admin_user
          resource.evaluator2 = current_active_admin_user
          resource.evaluator2_invalid_reasons = params[:impulsa_project][:invalid_reasons].strip
          resource.evaluator2_analysis = params[:impulsa_project][:evaluator_analysis]
          resource.check_evaluators_validation
          send_email = resource.save
        end
      elsif was_dissent
        send_email = resource.validated? || resource.invalidated?
      end
      
      if send_email
        if resource.fixes?
          ImpulsaMailer.on_fixes(resource).deliver_now
        elsif resource.validable?
          ImpulsaMailer.on_validable(resource).deliver_now
        elsif resource.invalidated?
          ImpulsaMailer.on_invalidated(resource).deliver_now
        elsif resource.validated?
          if resource.impulsa_edition_category.needs_preselection?
            ImpulsaMailer.on_validated1(resource).deliver_now
          else
            ImpulsaMailer.on_validated2(resource).deliver_now
          end
        end
      end
    end
  end

  csv do
    column :id
    column :name
    column :user_id
    column(:first_name) { |project| project.user.first_name }
    column(:last_name) { |project| project.user.last_name }
    column(:email) { |project| project.user.email }
    column(:phone) { |project| project.user.phone }
    column(:town_name) { |project| project.user.town_name }
    column(:impulsa_edition_category) { |project| project.impulsa_edition_category.name }

    column :votes
  end

end
