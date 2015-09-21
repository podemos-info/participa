ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params ImpulsaProject::ALL_FIELDS + ImpulsaProject::ADMIN_REVIEWABLE_FIELDS.map {|f| "#{f}_review".to_sym }, impulsa_edition_topic_ids: []

  filter :impulsa_edition_topics, as: :select, collection: -> { parent.impulsa_edition_topics}
  filter :impulsa_edition_category, as: :select, collection: -> { parent.impulsa_edition_categories}
  filter :authority
  filter :authority_name

  index do
    selectable_column
    column :id
    column :name do |impulsa_project|
      link_to impulsa_project.name, admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
    end
    column :user
    column :total_budget
    column :impulsa_edition_category
    column :status_name do |impulsa_project|
      div t("podemos.impulsa.project_status.#{ImpulsaProject::PROJECT_STATUS.invert[impulsa_project.status]}")
      if impulsa_project.editable?
        impulsa_project.mark_for_review
        if impulsa_project.valid?
          status_tag("OK", :ok)
        else
          status_tag("#{impulsa_project.errors.keys.length} errores", :error)
        end
      end
    end
    actions
  end

  action_item(:reviews, only: [:show, :edit] ) do
    content_tag :script do
      "window.review_fields = #{impulsa_project.review_fields.to_json};".html_safe
    end
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
          link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user)) if impulsa_project.user
        end
        row :status do
          t("podemos.impulsa.project_status.#{ImpulsaProject::PROJECT_STATUS.invert[impulsa_project.status]}")
        end
        row :additional_contact
        row :counterpart_information
      end
    end

    panel t("podemos.impulsa.project_data_section") do
      attributes_table_for impulsa_project do
        row :name
        row :short_description
        row :logo do
          image_tag(impulsa_project.logo.url(:thumb)) if impulsa_project.logo.exists?
        end
        row :video_link
      end
    end

    panel "Temáticas" do
      table_for impulsa_project.impulsa_edition_topics do
        column :name
      end
    end

    if impulsa_project.needs_authority?
      panel t("podemos.impulsa.project_data_section") do
      attributes_table_for impulsa_project do
          row :authority
          row :authority_name
          row :authority_phone
          row :authority_email
        end
      end
    end

    panel t("podemos.impulsa.organization_data_section") do
      attributes_table_for impulsa_project do
        row :organization_type do |impulsa_project|
          t("podemos.impulsa.organization_type.#{impulsa_project.organization_type_name}") if impulsa_project.organization_type
        end 
        row :organization_name
        row :organization_address
        row :organization_web
        row :organization_nif
        row :scanned_nif do |impulsa_project|
          link_to(impulsa_project.scanned_nif_file_name, impulsa_project.scanned_nif.url) if impulsa_project.scanned_nif.exists?
        end
        row :organization_year
        row :organization_legal_name
        row :organization_legal_nif
        row :organization_mission
        row :career
      end
    end

    panel t("podemos.impulsa.documents_section") do
      attributes_table_for impulsa_project do
        row :endorsement do |impulsa_project|
          link_to(impulsa_project.endorsement_file_name, impulsa_project.endorsement.url) if impulsa_project.endorsement.exists?
        end
        row :register_entry do |impulsa_project|
          link_to(impulsa_project.register_entry_file_name, impulsa_project.register_entry.url) if impulsa_project.register_entry.exists?
        end
        row :statutes do |impulsa_project|
          link_to(impulsa_project.statutes_file_name, impulsa_project.statutes.url) if impulsa_project.statutes.exists?
        end
        row :responsible_nif do |impulsa_project|
          link_to(impulsa_project.responsible_nif_file_name, impulsa_project.responsible_nif.url) if impulsa_project.responsible_nif.exists?
        end
        row :fiscal_obligations_certificate do |impulsa_project|
          link_to(impulsa_project.fiscal_obligations_certificate_file_name, impulsa_project.fiscal_obligations_certificate.url) if impulsa_project.fiscal_obligations_certificate.exists?
        end
        row :labor_obligations_certificate do |impulsa_project|
          link_to(impulsa_project.labor_obligations_certificate_file_name, impulsa_project.labor_obligations_certificate.url) if impulsa_project.labor_obligations_certificate.exists?
        end
        row :last_fiscal_year_report_of_activities do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_report_of_activities_file_name, impulsa_project.last_fiscal_year_report_of_activities.url) if impulsa_project.last_fiscal_year_report_of_activities.exists?
        end
        row :last_fiscal_year_annual_accounts do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_annual_accounts_file_name, impulsa_project.last_fiscal_year_annual_accounts.url) if impulsa_project.last_fiscal_year_annual_accounts.exists?
        end
      end
    end

    panel t("podemos.impulsa.project_progress_section") do
      attributes_table_for impulsa_project do
        row :long_description
        row :territorial_context
        row :aim
        row :metodology
        row :population_segment
        row :counterpart
        row :schedule do |impulsa_project|
          link_to(impulsa_project.schedule_file_name, impulsa_project.schedule.url) if impulsa_project.schedule.exists?
        end
        row :activities_resources do |impulsa_project|
          link_to(impulsa_project.activities_resources_file_name, impulsa_project.activities_resources.url) if impulsa_project.activities_resources.exists?
        end
        row :total_budget
        row :requested_budget do |impulsa_project|
          link_to(impulsa_project.requested_budget_file_name, impulsa_project.requested_budget.url) if impulsa_project.requested_budget.exists?
        end
        row :monitoring_evaluation do |impulsa_project|
          link_to(impulsa_project.monitoring_evaluation_file_name, impulsa_project.monitoring_evaluation.url) if impulsa_project.monitoring_evaluation.exists?
        end
      end
    end

    if impulsa_project.translatable?
      panel t("podemos.impulsa.translation_section") do
        attributes_table_for impulsa_project do
          row :coofficial_translation
          row :coofficial_name
          row :coofficial_short_description
          row :coofficial_video_link
          row :coofficial_territorial_context
          row :coofficial_long_description
          row :coofficial_aim
          row :coofficial_metodology
          row :coofficial_population_segment
          row :coofficial_organization_mission
          row :coofficial_career
        end
      end
    end
  end

  form do |f|
    f.inputs t("podemos.impulsa.admin_section") do
      li do
        label "Edition"
        div class: :readonly do link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition)) end
      end
      f.input :impulsa_edition_category, hint: link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(resource.impulsa_edition, resource.impulsa_edition_category))
      if impulsa_project.user
        f.input :user_id, as: :number, hint: link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user))
      else
        f.input :user_id, as: :number
      end
      f.input :status, as: :select, collection: ImpulsaProject::PROJECT_STATUS.map { |k,v| [ t("podemos.impulsa.project_status.#{k}"), v ]}
      f.input :additional_contact
      f.input :counterpart_information
    end
    f.inputs t("podemos.impulsa.project_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :name
      f.input :impulsa_edition_topics, as: :check_boxes
      f.input :short_description
      f.input :logo, as: :file, hint: proc{ f.template.image_tag(f.object.logo.url(:thumb)) if f.object_has_logo?}
      f.input :video_link
    end
    if impulsa_project.needs_authority?
      f.inputs t("podemos.impulsa.project_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
        f.input :authority
        f.input :authority_name
        f.input :authority_phone
        f.input :authority_email
      end
    end
    f.inputs t("podemos.impulsa.organization_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :organization_type, as: :select, collection: ImpulsaProject::ORGANIZATION_TYPES.map { |k,v| [ t("podemos.impulsa.organization_type.#{k}"), v ]} 
      f.input :organization_name
      f.input :organization_address
      f.input :organization_web
      f.input :organization_nif
      f.input :scanned_nif, as: :file
      f.input :organization_year
      f.input :organization_legal_name
      f.input :organization_legal_nif
      f.input :organization_mission
      f.input :career
    end
    f.inputs t("podemos.impulsa.documents_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :endorsement, as: :file
      f.input :register_entry, as: :file
      f.input :statutes, as: :file
      f.input :responsible_nif, as: :file
      f.input :fiscal_obligations_certificate, as: :file
      f.input :labor_obligations_certificate, as: :file
      f.input :last_fiscal_year_report_of_activities, as: :file
      f.input :last_fiscal_year_annual_accounts, as: :file
    end
    f.inputs t("podemos.impulsa.project_progress_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :counterpart
      f.input :territorial_context
      f.input :long_description
      f.input :aim
      f.input :metodology
      f.input :population_segment
      f.input :schedule, as: :file
      f.input :activities_resources, as: :file
      f.input :total_budget
      f.input :requested_budget, as: :file
      f.input :monitoring_evaluation, as: :file
    end
    if impulsa_project.translatable?
      f.inputs t("podemos.impulsa.translation_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
        f.input :coofficial_translation
        f.input :coofficial_name
        f.input :coofficial_short_description
        f.input :coofficial_video_link
        f.input :coofficial_territorial_context
        f.input :coofficial_long_description
        f.input :coofficial_aim
        f.input :coofficial_metodology
        f.input :coofficial_population_segment
        f.input :coofficial_organization_mission
        f.input :coofficial_career
      end
    end
    f.actions
  end

  controller do
    before_filter :update_scopes, :only => :index

    def update_scopes
      resource = active_admin_config

      ImpulsaProject::PROJECT_STATUS.each do |status, id|
        status_name = t("podemos.impulsa.project_status.#{status}")
        if !resource.scopes.any? { |scope| scope.name == status_name }
          resource.scopes << ActiveAdmin::Scope.new( status_name ) do |projects| projects.by_status(id) end
        end
      end
    end
  end
end
