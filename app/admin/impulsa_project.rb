ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params ImpulsaProject::ALL_FIELDS + ImpulsaProject::ADMIN_REVIEWABLE_FIELDS.map {|f| "#{f}_review".to_sym }, impulsa_edition_topic_ids: []

  filter :impulsa_edition_topics, as: :select, collection: -> { parent.impulsa_edition_topics}
  filter :impulsa_edition_category, as: :select, collection: -> { parent.impulsa_edition_categories}
  filter :name
  filter :user_id
  filter :id_in, as: :string, label: "Lista de IDs de proyectos", required: false
  filter :user_email_contains
  filter :authority
  filter :authority_name

  index download_links: -> { can?(:admin, ImpulsaProject) } do
    selectable_column
    column :id
    column :logo do |impulsa_project|
      ( impulsa_project.video_link.blank? ? status_tag("SIN VIDEO", :error) : a( status_tag("VER VIDEO", :ok), href: url_for(impulsa_project.video_link), target: "_blank" ) ) + br +
      ( impulsa_project.logo.blank? ? status_tag("SIN FOTO", :error) : a( image_tag(impulsa_project.logo.url(:thumb)), href: impulsa_project.logo.url ) )
    end
    column :name do |impulsa_project|
      link_to impulsa_project.name, admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
    end
    column :user
    column :impulsa_edition_category
    column :total_budget do |impulsa_project|
      div :class => "moneda" do
        number_to_currency impulsa_project.total_budget, :unit => "€"
      end
    end
    #column :updated_at
    column :status_name do |impulsa_project|
      div t("podemos.impulsa.project_status.#{ImpulsaProject::PROJECT_STATUS.invert[impulsa_project.status]}")
      if impulsa_project.saveable?
        impulsa_project.check_validation = true
        if impulsa_project.valid?
          status_tag("OK", :ok)
        else
          status_tag("#{impulsa_project.errors.keys.length} errores", :error)
        end
      end
    end
    column :votes
    actions
  end

  action_item(:reviews, only: [:show, :edit] ) do
    content_tag :script do
      "window.review_fields = #{impulsa_project.review_fields.to_json};".html_safe
    end
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

  show do
    impulsa_project.check_validation = true
    impulsa_project.valid?
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
        row :status do
          t("podemos.impulsa.project_status.#{ImpulsaProject::PROJECT_STATUS.invert[impulsa_project.status]}")
        end
        row :additional_contact
        row :counterpart_information
        row :created_at
        row :updated_at
      end
    end

    panel t("podemos.impulsa.project_data_section") do
      attributes_table_for impulsa_project do
        row :name, class: "row-name " + impulsa_project.field_class(:name)
        row :short_description, class: "row-short_description " + impulsa_project.field_class(:short_description)
        row :logo, class: "row-logo " + impulsa_project.field_class(:logo) do
          image_tag(impulsa_project.logo.url(:thumb)) if impulsa_project.logo.exists?
        end
        row :video_link, class: "row-video_link " + impulsa_project.field_class(:video_link)
      end
    end

    panel "Temáticas" do
      table_for impulsa_project.impulsa_edition_topics, class: "row-impulsa_edition_topics " + impulsa_project.field_class(:impulsa_edition_topics) do
        column :name
      end
    end

    panel t("podemos.impulsa.authority_data_section") do
      attributes_table_for impulsa_project do
        row :authority, class: "row-authority " + impulsa_project.field_class(:authority)
        row :authority_name, class: "row-authority_name " + impulsa_project.field_class(:authority_name)
        row :authority_phone, class: "row-authority_phone " + impulsa_project.field_class(:authority_phone)
        row :authority_email, class: "row-authority_email " + impulsa_project.field_class(:authority_email)
      end
    end

    panel t("podemos.impulsa.organization_data_section") do
      attributes_table_for impulsa_project do
        row :organization_type, class: "row-organization_type " +  impulsa_project.field_class(:organization_type) do |impulsa_project|
          t("podemos.impulsa.organization_type.#{impulsa_project.organization_type_name}") if impulsa_project.organization_type
        end
        row :organization_name, class: "row-organization_name " + impulsa_project.field_class(:organization_name)
        row :organization_address, class: "row-organization_address " + impulsa_project.field_class(:organization_address)
        row :organization_web, class: "row-organization_web " + impulsa_project.field_class(:organization_web)
        row :organization_nif, class: "row-organization_nif " + impulsa_project.field_class(:organization_nif)
        row :scanned_nif, class: "row-scanned_nif " + impulsa_project.field_class(:scanned_nif) do |impulsa_project|
          link_to(impulsa_project.scanned_nif_file_name, impulsa_project.scanned_nif.url) if impulsa_project.scanned_nif.exists?
        end
        row :organization_year, class: "row-organization_year " + impulsa_project.field_class(:organization_year)
        row :organization_legal_name, class: "row-organization_legal_name " + impulsa_project.field_class(:organization_legal_name)
        row :organization_legal_nif, class: "row-organization_legal_nif " + impulsa_project.field_class(:organization_legal_nif)
        row :organization_mission, class: "row-organization_mission " + impulsa_project.field_class(:organization_mission)
        row :career, class: "row-career " + impulsa_project.field_class(:career)
      end
    end

    panel t("podemos.impulsa.documents_section") do
      attributes_table_for impulsa_project do
        row :endorsement, class: "row-endorsement " + impulsa_project.field_class(:endorsement) do |impulsa_project|
          link_to(impulsa_project.endorsement_file_name, impulsa_project.endorsement.url) if impulsa_project.endorsement.exists?
        end
        row :register_entry, class: "row-register_entry " + impulsa_project.field_class(:register_entry) do |impulsa_project|
          link_to(impulsa_project.register_entry_file_name, impulsa_project.register_entry.url) if impulsa_project.register_entry.exists?
        end
        row :statutes, class: "row-statutes " + impulsa_project.field_class(:statutes) do |impulsa_project|
          link_to(impulsa_project.statutes_file_name, impulsa_project.statutes.url) if impulsa_project.statutes.exists?
        end
        row :responsible_nif, class: "row-responsible_nif " + impulsa_project.field_class(:responsible_nif) do |impulsa_project|
          link_to(impulsa_project.responsible_nif_file_name, impulsa_project.responsible_nif.url) if impulsa_project.responsible_nif.exists?
        end
        row :fiscal_obligations_certificate, class: "row-fiscal_obligations_certificate " + impulsa_project.field_class(:fiscal_obligations_certificate) do |impulsa_project|
          link_to(impulsa_project.fiscal_obligations_certificate_file_name, impulsa_project.fiscal_obligations_certificate.url) if impulsa_project.fiscal_obligations_certificate.exists?
        end
        row :labor_obligations_certificate, class: "row-labor_obligations_certificate " + impulsa_project.field_class(:labor_obligations_certificate) do |impulsa_project|
          link_to(impulsa_project.labor_obligations_certificate_file_name, impulsa_project.labor_obligations_certificate.url) if impulsa_project.labor_obligations_certificate.exists?
        end
        row :last_fiscal_year_report_of_activities, class: "row-last_fiscal_year_report_of_activities " + impulsa_project.field_class(:last_fiscal_year_report_of_activities) do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_report_of_activities_file_name, impulsa_project.last_fiscal_year_report_of_activities.url) if impulsa_project.last_fiscal_year_report_of_activities.exists?
        end
        row :last_fiscal_year_annual_accounts, class: "row-last_fiscal_year_annual_accounts " + impulsa_project.field_class(:last_fiscal_year_annual_accounts) do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_annual_accounts_file_name, impulsa_project.last_fiscal_year_annual_accounts.url) if impulsa_project.last_fiscal_year_annual_accounts.exists?
        end
      end
    end

    panel t("podemos.impulsa.project_progress_section") do
      attributes_table_for impulsa_project do
        row :long_description, class: "row-long_description " + impulsa_project.field_class(:long_description)
        row :territorial_context, class: "row-territorial_context " + impulsa_project.field_class(:territorial_context)
        row :aim, class: "row-aim " + impulsa_project.field_class(:aim)
        row :metodology, class: "row-metodology " + impulsa_project.field_class(:metodology)
        row :population_segment, class: "row-population_segment " + impulsa_project.field_class(:population_segment)
        row :counterpart, class: "row-counterpart " + impulsa_project.field_class(:counterpart)
        row :schedule, class: "row-schedule " + impulsa_project.field_class(:schedule) do |impulsa_project|
          link_to(impulsa_project.schedule_file_name, impulsa_project.schedule.url) if impulsa_project.schedule.exists?
        end
        row :activities_resources, class: "row-activities_resources " + impulsa_project.field_class(:activities_resources) do |impulsa_project|
          link_to(impulsa_project.activities_resources_file_name, impulsa_project.activities_resources.url) if impulsa_project.activities_resources.exists?
        end
        row :total_budget, class: "row-total_budget " + impulsa_project.field_class(:total_budget)
        row :requested_budget, class: "row-requested_budget " + impulsa_project.field_class(:requested_budget) do |impulsa_project|
          link_to(impulsa_project.requested_budget_file_name, impulsa_project.requested_budget.url) if impulsa_project.requested_budget.exists?
        end
        row :monitoring_evaluation, class: "row-monitoring_evaluation " + impulsa_project.field_class(:monitoring_evaluation) do |impulsa_project|
          link_to(impulsa_project.monitoring_evaluation_file_name, impulsa_project.monitoring_evaluation.url) if impulsa_project.monitoring_evaluation.exists?
        end
      end
    end

    if impulsa_project.translatable?
      panel t("podemos.impulsa.translation_section") do
        attributes_table_for impulsa_project do
          row :coofficial_translation, class: "row-coofficial_translation " + impulsa_project.field_class(:coofficial_translation)
          row :coofficial_name, class: "row-coofficial_name " + impulsa_project.field_class(:coofficial_name)
          row :coofficial_short_description, class: "row-coofficial_short_description " + impulsa_project.field_class(:coofficial_short_description)
          row :coofficial_video_link, class: "row-coofficial_video_link " + impulsa_project.field_class(:coofficial_video_link)
          row :coofficial_territorial_context, class: "row-coofficial_territorial_context " + impulsa_project.field_class(:coofficial_territorial_context)
          row :coofficial_long_description, class: "row-coofficial_long_description " + impulsa_project.field_class(:coofficial_long_description)
          row :coofficial_aim, class: "row-coofficial_aim " + impulsa_project.field_class(:coofficial_aim)
          row :coofficial_metodology, class: "row-coofficial_metodology " + impulsa_project.field_class(:coofficial_metodology)
          row :coofficial_population_segment, class: "row-coofficial_population_segment " + impulsa_project.field_class(:coofficial_population_segment)
          row :coofficial_organization_mission, class: "row-coofficial_organization_mission " + impulsa_project.field_class(:coofficial_organization_mission)
          row :coofficial_career, class: "row-coofficial_career " + impulsa_project.field_class(:coofficial_career)
        end
      end
    end

    panel "Evaluación" do
      attributes_table_for impulsa_project do
        row :evaluator1
        row :evaluator1_invalid_reasons
        row :evaluator1_analysis do |impulsa_project|
          link_to(impulsa_project.evaluator1_analysis_file_name, impulsa_project.evaluator1_analysis.url) if impulsa_project.evaluator1_analysis.exists?
        end
        row :evaluator2
        row :evaluator2_invalid_reasons
        row :evaluator2_analysis do |impulsa_project|
          link_to(impulsa_project.evaluator2_analysis_file_name, impulsa_project.evaluator2_analysis.url) if impulsa_project.evaluator2_analysis.exists?
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    impulsa_project.check_validation = true
    impulsa_project.valid?
    f.inputs t("podemos.impulsa.admin_section") do
      li do
        label "Edition"
        div class: :readonly do link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition)) end
      end if impulsa_project.impulsa_edition
      if impulsa_project.impulsa_edition_category
        f.input :impulsa_edition_category, hint: link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(resource.impulsa_edition, resource.impulsa_edition_category))
      else
        f.input :impulsa_edition_category
      end
      if impulsa_project.user
        f.input :user_id, as: :number, hint: link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user))
      else
        f.input :user_id, as: :number
      end
      if can? :admin, ImpulsaProject
        f.input :status, as: :select, collection: ImpulsaProject::PROJECT_STATUS.map { |k,v| [ t("podemos.impulsa.project_status.#{k}"), v ]}
      end
      f.input :additional_contact
      f.input :counterpart_information
      f.input :votes
    end
    f.inputs t("podemos.impulsa.project_data_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
      f.input :name
      f.input :impulsa_edition_topics, as: :check_boxes, wrapper_html: { class: f.object.field_class(:impulsa_edition_topic_ids) }
      f.input :short_description
      f.input :logo, as: :file, hint: proc{ f.template.image_tag(f.object.logo.url(:thumb)) if f.object_has_logo?}
      f.input :video_link
    end
    f.inputs t("podemos.impulsa.authority_data_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
      f.input :authority, wrapper_html: { class: f.object.field_class(:authority) }
      f.input :authority_name, wrapper_html: { class: f.object.field_class(:authority_name) }
      f.input :authority_phone, wrapper_html: { class: f.object.field_class(:authority_phone) }
      f.input :authority_email, wrapper_html: { class: f.object.field_class(:authority_email) }
    end
    f.inputs t("podemos.impulsa.organization_data_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
      f.input :organization_type, as: :select, collection: ImpulsaProject::ORGANIZATION_TYPES.map { |k,v| [ t("podemos.impulsa.organization_type.#{k}"), v ]}, wrapper_html: { class: f.object.field_class(:organization_type) }
      f.input :organization_name, wrapper_html: { class: f.object.field_class(:organization_name) }
      f.input :organization_address, wrapper_html: { class: f.object.field_class(:organization_address) }
      f.input :organization_web, wrapper_html: { class: f.object.field_class(:organization_web) }
      f.input :organization_nif, wrapper_html: { class: f.object.field_class(:organization_nif) }
      f.input :scanned_nif, as: :file, wrapper_html: { class: f.object.field_class(:scanned_nif) }
      f.input :organization_year, wrapper_html: { class: f.object.field_class(:organization_year) }
      f.input :organization_legal_name, wrapper_html: { class: f.object.field_class(:organization_legal_name) }
      f.input :organization_legal_nif, wrapper_html: { class: f.object.field_class(:organization_legal_nif) }
      f.input :organization_mission, wrapper_html: { class: f.object.field_class(:organization_mission) }
      f.input :career, wrapper_html: { class: f.object.field_class(:career) }
    end
    f.inputs t("podemos.impulsa.documents_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
      f.input :endorsement, as: :file, wrapper_html: { class: f.object.field_class(:endorsement) }
      f.input :register_entry, as: :file, wrapper_html: { class: f.object.field_class(:register_entry) }
      f.input :statutes, as: :file, wrapper_html: { class: f.object.field_class(:statutes) }
      f.input :responsible_nif, as: :file, wrapper_html: { class: f.object.field_class(:responsible_nif) }
      f.input :fiscal_obligations_certificate, as: :file, wrapper_html: { class: f.object.field_class(:fiscal_obligations_certificate) }
      f.input :labor_obligations_certificate, as: :file, wrapper_html: { class: f.object.field_class(:labor_obligations_certificate) }
      f.input :last_fiscal_year_report_of_activities, as: :file, wrapper_html: { class: f.object.field_class(:last_fiscal_year_report_of_activities) }
      f.input :last_fiscal_year_annual_accounts, as: :file, wrapper_html: { class: f.object.field_class(:last_fiscal_year_annual_accounts) }
    end
    f.inputs t("podemos.impulsa.project_progress_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
      f.input :counterpart, wrapper_html: { class: f.object.field_class(:counterpart) }
      f.input :territorial_context, wrapper_html: { class: f.object.field_class(:territorial_context) }
      f.input :long_description, wrapper_html: { class: f.object.field_class(:long_description) }
      f.input :aim, wrapper_html: { class: f.object.field_class(:aim) }
      f.input :metodology, wrapper_html: { class: f.object.field_class(:metodology) }
      f.input :population_segment, wrapper_html: { class: f.object.field_class(:population_segment) }
      f.input :schedule, as: :file, wrapper_html: { class: f.object.field_class(:schedule) }
      f.input :activities_resources, as: :file, wrapper_html: { class: f.object.field_class(:activities_resources) }
      f.input :total_budget, wrapper_html: { class: f.object.field_class(:total_budget) }
      f.input :requested_budget, as: :file, wrapper_html: { class: f.object.field_class(:requested_budget) }
      f.input :monitoring_evaluation, as: :file, wrapper_html: { class: f.object.field_class(:monitoring_evaluation) }
    end
    if impulsa_project.translatable?
      f.inputs t("podemos.impulsa.translation_section"), class: f.object.saveable? ? "inputs reviewable" : "inputs" do
        f.input :coofficial_translation, wrapper_html: { class: f.object.field_class(:coofficial_translation) }
        f.input :coofficial_name, wrapper_html: { class: f.object.field_class(:coofficial_name) }
        f.input :coofficial_short_description, wrapper_html: { class: f.object.field_class(:coofficial_short_description) }
        f.input :coofficial_video_link, wrapper_html: { class: f.object.field_class(:coofficial_video_link) }
        f.input :coofficial_territorial_context, wrapper_html: { class: f.object.field_class(:coofficial_territorial_context) }
        f.input :coofficial_long_description, wrapper_html: { class: f.object.field_class(:coofficial_long_description) }
        f.input :coofficial_aim, wrapper_html: { class: f.object.field_class(:coofficial_aim) }
        f.input :coofficial_metodology, wrapper_html: { class: f.object.field_class(:coofficial_metodology) }
        f.input :coofficial_population_segment, wrapper_html: { class: f.object.field_class(:coofficial_population_segment) }
        f.input :coofficial_organization_mission, wrapper_html: { class: f.object.field_class(:coofficial_organization_mission) }
        f.input :coofficial_career, wrapper_html: { class: f.object.field_class(:coofficial_career) }
      end
    end

    if impulsa_project.saveable?
      f.inputs "Revisión del proyecto" do
        li do
          "Al utilizar esta casilla el proyecto cambiará de estado: si hay comentarios asociados a algún campo pasar al estado 'Correcciones' 
          para que sea revisado por el usuario; en caso contrario pasará al estado 'Validar'. En cualquier caso, se enviará un correo al usuario
          para informarle del progreso de su proyecto, por lo que es recomendable revisar el formulario antes de enviarlo." 
        end
        f.input :mark_as_viewed, label: "Marcar como revisado", as: :boolean
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

  controller do
    before_filter :update_scopes, :only => :index
    before_filter :multiple_id_search, :only => :index

    def multiple_id_search
      params[:q][:id_in] = params[:q][:id_in].split unless params[:q].nil? or params[:q][:id_in].nil?
    end

    def update_scopes
      resource = active_admin_config

      ImpulsaProject::PROJECT_STATUS.each do |status, id|
        status_name = t("podemos.impulsa.project_status.#{status}")
        if !resource.scopes.any? { |scope| scope.name == status_name }
          resource.scopes << ActiveAdmin::Scope.new( status_name ) do |projects| projects.by_status(id) end
        end
      end
    end

    def update
      send_email = false
      was_dissent = resource.dissent?
      super
      if resource.saveable? && params[:impulsa_project][:mark_as_viewed]
        if resource.review_fields.any?
          resource.mark_as_fixable
        else
          resource.mark_as_validable
        end
        send_email = resource.save
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
    column :total_budget
    column(:impulsa_edition_category) { |project| project.impulsa_edition_category.name }
    column(:impulsa_edition_topics) { |project| project.impulsa_edition_topics.map{|t| t.name }.join("|") }
    column :short_description
    column(:logo) { |project| "#{request.protocol}#{request.host}#{project.logo.url}" }
    column :video_link
    column :organization_name
    column :organization_web
    column :organization_year
    column :organization_mission
    column :career
    column :territorial_context
    column :aim
    column :metodology
    column :population_segment
    column :counterpart
  end

end
