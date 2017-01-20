ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params do
    ps = [:review, :validable, :name, :impulsa_edition_category_id, :evaluation_result]
    all_fields = resource.wizard_step_admin_params

    if params[:review]=="true"
      all_fields.concat(all_fields.pop.keys) if all_fields.last.is_a?(Hash)  # last param could be a hash for multivalue fields  
      ps.concat(all_fields.map {|param| "_rvw"+param[4..-1]}) if resource.reviewable?    # add review fields
    elsif params[:validable]=="true"
      ps.concat(resource.evaluation_admin_params)
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
    column :state do |impulsa_project|
      div impulsa_project.state
      if impulsa_project.wizard_has_errors?
        status_tag("#{impulsa_project.wizard_count_errors} errores", :error)
      else
        status_tag("OK", :ok)
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

  action_item(:review, only: :show ) do
    link_to('Marcar para revision', review_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project), method: :post, data: { confirm: "¿Estas segura de querer marcar este proyecto para revisión?" }) if impulsa_project.markable_for_review?
  end

  member_action :review, :method => :post do
    p = ImpulsaProject.find( params[:id] )
    p.mark_for_review
    p.save
    flash[:notice] = "El proyecto ha sido marcado para revisión."
    redirect_to action: :index
  end

  member_action :download_attachment do
    project = ImpulsaProject.find( params[:id] )
    send_file project.wizard_path(params[:gname], params[:fname])
  end

  action_item(:reset_evaluator, only: :show ) do
    link_to('Abandonar evaluación',reset_evaluator_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project), method: :post, data: { confirm: "Si abandonas se perderán los datos introducidos por ti en el formulario de evaluación. ¿Deseas continuar?" }) if impulsa_project.is_current_evaluator?(current_active_admin_user.id)
  end

  member_action :reset_evaluator, :method => :post do
    p = ImpulsaProject.find( params[:id] )
    p.reset_evaluator(current_active_admin_user.id)
    p.save
    flash[:notice] = "Has abandonado la evaluación del proyecto, cualquier usuario podrá realizarla en tu lugar."
    redirect_to action: :index
  end

  sidebar "Subir resultados de votación", 'data-panel' => :collapsed, :only => :index, priority: 1 do  
    render("admin/upload_vote_results_form")
  end

  show do
    panel t("podemos.impulsa.admin_section") do
      attributes_table_for impulsa_project do
        row :id
        row :edition do 
          link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition))
        end
        row :category do
          link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(impulsa_project.impulsa_edition, resource.impulsa_edition_category))
        end
        row :state
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
        row :created_at
        row :updated_at
        row "Evaluation" do
          impulsa_project.evaluation_result
        end if impulsa_project.evaluation_result.present?
      end
    end

    form method: :post do |f|
      input type: :hidden, name: :_method, value: :patch
      input type: :hidden, name: :review, value: impulsa_project.reviewable?
      input type: :hidden, name: :validable, value: impulsa_project.validable?
      input type: :hidden, name: :authenticity_token, value: form_authenticity_token
      
      errors = Hash[impulsa_project.wizard_all_errors.map {|gname, fname, error| ["#{gname}.#{fname}", error] }]
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
                    if value
                      div link_to(value, download_attachment_admin_impulsa_edition_impulsa_project_path(id: impulsa_project.id, fname: fname, gname: gname))
                    else
                      div ""
                    end
                  else
                    div value
                  end
                end
                row "error", class: "error" do
                  errors["#{gname}.#{fname}"]
                end if errors["#{gname}.#{fname}"]
                row "revisión", class: "review #{'remark' if impulsa_project.wizard_review["#{gname}.#{fname}"].present?}" do
                  textarea(impulsa_project.wizard_review["#{gname}.#{fname}"], id: "impulsa_project__rvw_#{gname}__#{fname}", name: "impulsa_project[_rvw_#{gname}__#{fname}]", rows: 2) 
                end if impulsa_project.reviewable?
              end
            end
          end
        end
      end

      panel "Acciones" do
        fieldset class: :actions do
          ol do 
            li class: "action input_action ", id: "impulsa_project_submit_action" do
              input type: :submit, value: "Marcar como revisado"
            end
          end
        end
      end if impulsa_project.reviewable?

      if impulsa_project.validable?
        evaluator = impulsa_project.current_evaluator(current_active_admin_user.id)
        impulsa_project.evaluator[evaluator] = current_active_admin_user if evaluator
        
        panel "Evaluación", class:"evaluation" do
          fieldset class: "inputs" do
            legend do
              span "Evaluadores"
            end
            ol do
              impulsa_project.evaluators.each do |i|
                e = impulsa_project.evaluator[i]
                li class: "input" do 
                  label "Evaluador #{i}", class: :label
                  div e.full_name, class:"readonly"
                end if e.present?
              end
            end
          end

          impulsa_project.evaluation.each do |sname, step|
            fieldset class: "inputs" do
              legend do
                span step[:title]
              end
              ol do
                step[:groups].each do |gname, group|
                  li class: "input full" do h3 group[:title] if group[:title] end
                  group[:fields].each do |fname, field|
                    li class: "input full" do
                      label class:"label" do field[:title] end
                    end
                    impulsa_project.evaluators.each do |i|
                      e = impulsa_project.evaluator[i]
                      break if e.nil?
                      li class: "input input_#{i}" do
                        label class:"label" do impulsa_project.evaluator[i].full_name end
                        value = impulsa_project.evaluation_values(i)["#{gname}.#{fname}"]
                        if evaluator == i
                          field_name = "impulsa_project[_evl#{i}_#{gname}__#{fname}]"
                          if field[:type]=="text"
                            textarea(value, name: field_name, type: field[:type])
                          else
                            params = { name: field_name, type: field[:type], value: value }
                            params[:max] = field[:maximum] if field[:maximum]
                            params[:min] = field[:minimum] if field[:minimum]
                            params[:readonly] = true if field[:sum]
                            input params
                          end
                        else
                          div value, class:"readonly"
                        end
                      end
                    end
                  end
                end
              end
            end
          end      

          fieldset class: :actions do
            ol do 
              li class: "action input_action" do
                input type: :submit, value: "Guardar evaluación"
              end
            end
          end if evaluator
        end
      end

      if impulsa_project.can_finish_evaluation?(current_active_admin_user)
        panel "Finalizar evaluación" do
          ol do
            li class: "input" do
              label class:"label" do "Resultado de la evaluación" end
              input name: "impulsa_project[evaluation_result]", type:"text"
            end
          end
          fieldset class: :actions do
            ol do
              li class: "action input_action" do
                input type: :submit, name: "evaluation_action_ok", value: "Fase superada", "data-confirm"=>"Se avisará al usuario de esta decisión. ¿Deseas continuar?"
              end
              li class: "action input_action" do
                input type: :submit, name: "evaluation_action_ko", value: "Fase NO superada", "data-confirm"=>"Se avisará al usuario de esta decisión. ¿Deseas continuar?"
              end
            end
          end
        end
      end
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

      ImpulsaProject.state_machine.states.keys.each do |state|
        if resource.scopes.none? { |scope| scope.id.to_s == state.to_s }
          resource.scopes << ActiveAdmin::Scope.new( state ) do |projects| projects.where(state: state) end
        end
      end
    end

    def update
      send_email = false

      if resource.validable?
        evaluator = resource.current_evaluator(current_active_admin_user.id)
        resource.evaluator[evaluator] = current_active_admin_user if evaluator
      end
      super
      if resource.reviewable? && params[:review]
        if resource.wizard_has_errors?(ignore_state: true)
          resource.mark_as_fixes
        else
          resource.mark_as_validable
        end
        flash[:notice] = "El proyecto ha sido marcado como revisado."
        send_email = true
      elsif resource.validable? && resource.evaluation_result?
        if params[:evaluation_action_ok].present?
          resource.mark_as_validated
          send_email = true
          flash[:notice] = "El proyecto ha sido marcado como validado."
        elsif params[:evaluation_action_ko].present?
          resource.mark_as_invalidated
          send_email = true
          flash[:notice] = "El proyecto ha sido marcado como invalidado."
        end
      end
      
      if send_email
        if resource.fixes?
          ImpulsaMailer.on_fixes(resource).deliver_now
        elsif resource.validable?
          ImpulsaMailer.on_validable(resource).deliver_now
        elsif resource.invalidated?
          ImpulsaMailer.on_invalidated(resource).deliver_now
        elsif resource.validated?
          ImpulsaMailer.on_validated(resource).deliver_now
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
