ActiveAdmin.register ImpulsaProject do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params ImpulsaProject::ALL_FIELDS + ImpulsaProject::ADMIN_REVIEWABLE_FIELDS.map {|f| "#{f}_review".to_sym }, impulsa_edition_topic_ids: []

  filter :impulsa_edition_topics, as: :select, collection: -> { parent.impulsa_edition_topics}
  filter :impulsa_edition_category, as: :select, collection: -> { parent.impulsa_edition_categories}
  filter :name
  filter :user_id
  filter :authority
  filter :authority_name

  index download_links: -> { can?(:admin, ImpulsaProject) } do
    selectable_column
    column :id
    column :name do |impulsa_project|
      link_to impulsa_project.name, admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
    end
    column :user
    column :total_budget
    column :impulsa_edition_category
    column :updated_at
    column :status_name do |impulsa_project|
      div t("podemos.impulsa.project_status.#{ImpulsaProject::PROJECT_STATUS.invert[impulsa_project.status]}")
      if impulsa_project.editable?
        impulsa_project.check_validation = true
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
      table_for impulsa_project.impulsa_edition_topics, class: impulsa_project.field_class(:impulsa_edition_topics) do
        column :name
      end
    end

    panel t("podemos.impulsa.project_data_section") do
      attributes_table_for impulsa_project do
        row :authority, class: impulsa_project.field_class(:authority)
        row :authority_name, class: impulsa_project.field_class(:authority_name)
        row :authority_phone, class: impulsa_project.field_class(:authority_phone)
        row :authority_email, class: impulsa_project.field_class(:authority_email)
      end
    end

    panel t("podemos.impulsa.organization_data_section") do
      attributes_table_for impulsa_project do
        row :organization_type, class: impulsa_project.field_class(:organization_type) do |impulsa_project|
          t("podemos.impulsa.organization_type.#{impulsa_project.organization_type_name}") if impulsa_project.organization_type
        end
        row :organization_name, class: impulsa_project.field_class(:organization_name)
        row :organization_address, class: impulsa_project.field_class(:organization_address)
        row :organization_web, class: impulsa_project.field_class(:organization_web)
        row :organization_nif, class: impulsa_project.field_class(:organization_nif)
        row :scanned_nif, class: impulsa_project.field_class(:scanned_nif) do |impulsa_project|
          link_to(impulsa_project.scanned_nif_file_name, impulsa_project.scanned_nif.url) if impulsa_project.scanned_nif.exists?
        end
        row :organization_year, class: impulsa_project.field_class(:organization_year)
        row :organization_legal_name, class: impulsa_project.field_class(:organization_legal_name)
        row :organization_legal_nif, class: impulsa_project.field_class(:organization_legal_nif)
        row :organization_mission, class: impulsa_project.field_class(:organization_mission)
        row :career, class: impulsa_project.field_class(:career)
      end
    end

    panel t("podemos.impulsa.documents_section") do
      attributes_table_for impulsa_project do
        row :endorsement, class: impulsa_project.field_class(:endorsement) do |impulsa_project|
          link_to(impulsa_project.endorsement_file_name, impulsa_project.endorsement.url) if impulsa_project.endorsement.exists?
        end
        row :register_entry, class: impulsa_project.field_class(:register_entry) do |impulsa_project|
          link_to(impulsa_project.register_entry_file_name, impulsa_project.register_entry.url) if impulsa_project.register_entry.exists?
        end
        row :statutes, class: impulsa_project.field_class(:statutes) do |impulsa_project|
          link_to(impulsa_project.statutes_file_name, impulsa_project.statutes.url) if impulsa_project.statutes.exists?
        end
        row :responsible_nif, class: impulsa_project.field_class(:responsible_nif) do |impulsa_project|
          link_to(impulsa_project.responsible_nif_file_name, impulsa_project.responsible_nif.url) if impulsa_project.responsible_nif.exists?
        end
        row :fiscal_obligations_certificate, class: impulsa_project.field_class(:fiscal_obligations_certificate) do |impulsa_project|
          link_to(impulsa_project.fiscal_obligations_certificate_file_name, impulsa_project.fiscal_obligations_certificate.url) if impulsa_project.fiscal_obligations_certificate.exists?
        end
        row :labor_obligations_certificate, class: impulsa_project.field_class(:labor_obligations_certificate) do |impulsa_project|
          link_to(impulsa_project.labor_obligations_certificate_file_name, impulsa_project.labor_obligations_certificate.url) if impulsa_project.labor_obligations_certificate.exists?
        end
        row :last_fiscal_year_report_of_activities, class: impulsa_project.field_class(:last_fiscal_year_report_of_activities) do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_report_of_activities_file_name, impulsa_project.last_fiscal_year_report_of_activities.url) if impulsa_project.last_fiscal_year_report_of_activities.exists?
        end
        row :last_fiscal_year_annual_accounts, class: impulsa_project.field_class(:last_fiscal_year_annual_accounts) do |impulsa_project|
          link_to(impulsa_project.last_fiscal_year_annual_accounts_file_name, impulsa_project.last_fiscal_year_annual_accounts.url) if impulsa_project.last_fiscal_year_annual_accounts.exists?
        end
      end
    end

    panel t("podemos.impulsa.project_progress_section") do
      attributes_table_for impulsa_project do
        row :long_description, class: impulsa_project.field_class(:long_description)
        row :territorial_context, class: impulsa_project.field_class(:territorial_context)
        row :aim, class: impulsa_project.field_class(:aim)
        row :metodology, class: impulsa_project.field_class(:metodology)
        row :population_segment, class: impulsa_project.field_class(:population_segment)
        row :counterpart, class: impulsa_project.field_class(:counterpart)
        row :schedule, class: impulsa_project.field_class(:schedule) do |impulsa_project|
          link_to(impulsa_project.schedule_file_name, impulsa_project.schedule.url) if impulsa_project.schedule.exists?
        end
        row :activities_resources, class: impulsa_project.field_class(:activities_resources) do |impulsa_project|
          link_to(impulsa_project.activities_resources_file_name, impulsa_project.activities_resources.url) if impulsa_project.activities_resources.exists?
        end
        row :total_budget, class: impulsa_project.field_class(:total_budget)
        row :requested_budget, class: impulsa_project.field_class(:requested_budget) do |impulsa_project|
          link_to(impulsa_project.requested_budget_file_name, impulsa_project.requested_budget.url) if impulsa_project.requested_budget.exists?
        end
        row :monitoring_evaluation, class: impulsa_project.field_class(:monitoring_evaluation) do |impulsa_project|
          link_to(impulsa_project.monitoring_evaluation_file_name, impulsa_project.monitoring_evaluation.url) if impulsa_project.monitoring_evaluation.exists?
        end
      end
    end

    if impulsa_project.translatable?
      panel t("podemos.impulsa.translation_section") do
        attributes_table_for impulsa_project do
          row :coofficial_translation, class: impulsa_project.field_class(:coofficial_translation)
          row :coofficial_name, class: impulsa_project.field_class(:coofficial_name)
          row :coofficial_short_description, class: impulsa_project.field_class(:coofficial_short_description)
          row :coofficial_video_link, class: impulsa_project.field_class(:coofficial_video_link)
          row :coofficial_territorial_context, class: impulsa_project.field_class(:coofficial_territorial_context)
          row :coofficial_long_description, class: impulsa_project.field_class(:coofficial_long_description)
          row :coofficial_aim, class: impulsa_project.field_class(:coofficial_aim)
          row :coofficial_metodology, class: impulsa_project.field_class(:coofficial_metodology)
          row :coofficial_population_segment, class: impulsa_project.field_class(:coofficial_population_segment)
          row :coofficial_organization_mission, class: impulsa_project.field_class(:coofficial_organization_mission)
          row :coofficial_career, class: impulsa_project.field_class(:coofficial_career)
        end
      end
    end
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
      f.input :status, as: :select, collection: ImpulsaProject::PROJECT_STATUS.map { |k,v| [ t("podemos.impulsa.project_status.#{k}"), v ]}
      f.input :additional_contact
      f.input :counterpart_information
    end
    f.inputs t("podemos.impulsa.project_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :name
      f.input :impulsa_edition_topics, as: :check_boxes, wrapper_html: { class: f.object.field_class(:impulsa_edition_topics) }
      f.input :short_description
      f.input :logo, as: :file, hint: proc{ f.template.image_tag(f.object.logo.url(:thumb)) if f.object_has_logo?}
      f.input :video_link
    end
    f.inputs t("podemos.impulsa.authority_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :authority, wrapper_html: { class: f.object.field_class(:authority) }
      f.input :authority_name, wrapper_html: { class: f.object.field_class(:authority_name) }
      f.input :authority_phone, wrapper_html: { class: f.object.field_class(:authority_phone) }
      f.input :authority_email, wrapper_html: { class: f.object.field_class(:authority_email) }
    end
    f.inputs t("podemos.impulsa.organization_data_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
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
    f.inputs t("podemos.impulsa.documents_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
      f.input :endorsement, as: :file, wrapper_html: { class: f.object.field_class(:endorsement) }
      f.input :register_entry, as: :file, wrapper_html: { class: f.object.field_class(:register_entry) }
      f.input :statutes, as: :file, wrapper_html: { class: f.object.field_class(:statutes) }
      f.input :responsible_nif, as: :file, wrapper_html: { class: f.object.field_class(:responsible_nif) }
      f.input :fiscal_obligations_certificate, as: :file, wrapper_html: { class: f.object.field_class(:fiscal_obligations_certificate) }
      f.input :labor_obligations_certificate, as: :file, wrapper_html: { class: f.object.field_class(:labor_obligations_certificate) }
      f.input :last_fiscal_year_report_of_activities, as: :file, wrapper_html: { class: f.object.field_class(:last_fiscal_year_report_of_activities) }
      f.input :last_fiscal_year_annual_accounts, as: :file, wrapper_html: { class: f.object.field_class(:last_fiscal_year_annual_accounts) }
    end
    f.inputs t("podemos.impulsa.project_progress_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
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
      f.inputs t("podemos.impulsa.translation_section"), class: f.object.reviewable? ? "inputs reviewable" : "inputs" do
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
