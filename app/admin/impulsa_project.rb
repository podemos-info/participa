ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition_category
  navigation_menu :default
    
  fields = [ :impulsa_edition_category_id, :user_id, :status, :review_fields, :additional_contact, :counterpart_information, :name, :authority, :authority_name, :authority_phone, :authority_email, :organization_name, :organization_address, :organization_web, :organization_nif, :organization_year, :organization_legal_name, :organization_legal_nif, :organization_mission, :career, :counterpart, :territorial_context, :short_description, :long_description, :aim, :metodology, :population_segment, :video_link, :alternative_language, :alternative_name, :alternative_organization_mission, :alternative_territorial_context, :alternative_short_description, :alternative_long_description, :alternative_aim, :alternative_metodology, :alternative_population_segment, :logo, :endorsement, :register_entry, :statutes, :responsible_nif, :fiscal_obligations_certificate, :labor_obligations_certificate, :last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :schedule, :activities_resources, :requested_budget, :monitoring_evaluation, :endorsement, :register_entry, :statutes, :responsible_nif, :fiscal_obligations_certificate, :labor_obligations_certificate, :last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :impulsa_edition_topic_ids ]
  permit_params fields + fields.map {|f| "#{f}_review".to_sym }, impulsa_edition_topic_ids: []

  filter :name
  filter :authority
  filter :authority_name
  filter :impulsa_edition_topics

  index do
    selectable_column
    id_column
    column :name
    column :status_name
    column :user
    actions
  end

  action_item(:reviews, only: [:show, :edit] ) do
    content_tag :script do
      "window.review_fields = #{impulsa_project.review_fields.to_json};".html_safe
    end
  end

  show do
    panel "Datos internos" do
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
        row :status_name
        row :additional_contact
        row :counterpart_information
      end
    end

    panel "Información del proyecto" do
      attributes_table_for impulsa_project do
        row :name
        row :short_description
        row :long_description
        row :territorial_context
        row :aim
        row :metodology
        row :population_segment
        row :counterpart
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
      panel "Autoridad que avala el proyecto" do
      attributes_table_for impulsa_project do
          row :authority
          row :authority_name
          row :authority_phone
          row :authority_email
        end
      end
    end

    panel "Organización responsable del proyecto" do
      attributes_table_for impulsa_project do
        row :organization_name
        row :organization_address
        row :organization_web
        row :organization_nif
        row :organization_year
        row :organization_legal_name
        row :organization_legal_nif
        row :organization_mission
        row :career
      end
    end

    panel "Documentacion" do
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

    panel "Planificación" do
      attributes_table_for impulsa_project do
        row :schedule do |impulsa_project|
          link_to(impulsa_project.schedule_file_name, impulsa_project.schedule.url) if impulsa_project.schedule.exists?
        end
        row :activities_resources do |impulsa_project|
          link_to(impulsa_project.activities_resources_file_name, impulsa_project.activities_resources.url) if impulsa_project.activities_resources.exists?
        end
        row :requested_budget do |impulsa_project|
          link_to(impulsa_project.requested_budget_file_name, impulsa_project.requested_budget.url) if impulsa_project.requested_budget.exists?
        end
        row :monitoring_evaluation do |impulsa_project|
          link_to(impulsa_project.monitoring_evaluation_file_name, impulsa_project.monitoring_evaluation.url) if impulsa_project.monitoring_evaluation.exists?
        end
      end
    end

    panel "Traducción" do
      attributes_table_for impulsa_project do
        row :alternative_language
        row :alternative_name
        row :alternative_organization_mission
        row :alternative_territorial_context
        row :alternative_short_description
        row :alternative_long_description
        row :alternative_aim
        row :alternative_metodology
        row :alternative_population_segment
      end
    end
  end

  form do |f|
    f.inputs "Datos básicos" do
      f.input :impulsa_edition_category_id, as: :hidden
      li do
        label "Edition"
        div class: :readonly do link_to(impulsa_project.impulsa_edition.name, admin_impulsa_edition_path(impulsa_project.impulsa_edition)) end
      end
      li do
        label "Category"
        div class: :readonly do link_to(impulsa_project.impulsa_edition_category.name, admin_impulsa_edition_impulsa_edition_category_path(resource.impulsa_edition, resource.impulsa_edition_category)) end
      end
      if impulsa_project.user
        f.input :user_id, as: :number, hint: link_to(impulsa_project.user.full_name,admin_user_path(impulsa_project.user))
      else
        f.input :user_id, as: :number
      end
      f.input :status, as: :select, collection: ImpulsaProject::STATUS_NAMES.to_a
      f.input :additional_contact
      f.input :counterpart_information
    end
    f.inputs "Información del proyecto", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :name
      f.input :impulsa_edition_topics, as: :check_boxes
      f.input :short_description
      f.input :long_description
      f.input :territorial_context
      f.input :aim
      f.input :metodology
      f.input :population_segment
      f.input :counterpart
      f.input :logo, as: :file, hint: proc{ f.template.image_tag(f.object.logo.url(:thumb)) if f.object_has_logo?}
      f.input :video_link
    end
    if impulsa_project.needs_authority?
      f.inputs "Autoridad que avala el proyecto", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
        f.input :authority
        f.input :authority_name
        f.input :authority_phone
        f.input :authority_email
      end
    end
    f.inputs "Organización responsable del proyecto", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :organization_name
      f.input :organization_address
      f.input :organization_web
      f.input :organization_nif
      f.input :organization_year
      f.input :organization_legal_name
      f.input :organization_legal_nif
      f.input :organization_mission
      f.input :career
    end
    f.inputs "Documentacion", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :endorsement, as: :file
      f.input :register_entry, as: :file
      f.input :statutes, as: :file
      f.input :responsible_nif, as: :file
      f.input :fiscal_obligations_certificate, as: :file
      f.input :labor_obligations_certificate, as: :file
      f.input :last_fiscal_year_report_of_activities, as: :file
      f.input :last_fiscal_year_annual_accounts, as: :file
    end
    f.inputs "Planificación", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :schedule, as: :file
      f.input :activities_resources, as: :file
      f.input :requested_budget, as: :file
      f.input :monitoring_evaluation, as: :file
    end
    f.inputs "Traducción", class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :alternative_language
      f.input :alternative_name
      f.input :alternative_organization_mission
      f.input :alternative_territorial_context
      f.input :alternative_short_description
      f.input :alternative_long_description
      f.input :alternative_aim
      f.input :alternative_metodology
      f.input :alternative_population_segment
    end
    f.actions
  end

  controller do
    before_filter :update_scopes, :only => :index

    def update_scopes
      resource = active_admin_config

      ImpulsaProject::STATUS_NAMES.each do |status, id|
        if ! resource.scopes.any? { |scope| scope.name == status.to_s }
          resource.scopes << ActiveAdmin::Scope.new( status ) do |projects| projects.by_status(id) end
        end
      end
    end
  end
end
