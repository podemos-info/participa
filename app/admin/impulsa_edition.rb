ActiveAdmin.register ImpulsaEdition do
  menu :parent => "Participación"
  config.filters = false
  permit_params do
    fields = [:id, :name, :start_at, :new_projects_until, :review_projects_until, :validation_projects_until, :ends_at, :schedule_model, :activities_resources_model, :requested_budget_model, :monitoring_evaluation_model]
    fields += I18n.available_locales.map do |locale|
      :"legal_#{locale}"
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :start_at
    column :new_projects_until
    column :review_projects_until
    column :validation_projects_until
    column :ends_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :start_at
      row :new_projects_until
      row :review_projects_until
      row :validation_projects_until
      row :ends_at
      row :legal do |impulsa_edition|
        I18n.available_locales.each do |locale|
          span link_to(I18n.name_for_locale(locale), impulsa_edition[:legal]["legal_#{locale}"]) if !impulsa_edition[:legal]["legal_#{locale}"].blank?
        end .compact
      end
      row :schedule_model do |impulsa_edition|
        link_to impulsa_edition.schedule_model_file_name, impulsa_edition.schedule_model.url if impulsa_edition.schedule_model.exists?
      end
      row :activities_resources_model do |impulsa_edition|
        link_to impulsa_edition.activities_resources_model_file_name, impulsa_edition.activities_resources_model.url if impulsa_edition.activities_resources_model.exists?
      end
      row :requested_budget_model do |impulsa_edition|
        link_to impulsa_edition.requested_budget_model_file_name, impulsa_edition.requested_budget_model.url if impulsa_edition.requested_budget_model.exists?
      end
      row :monitoring_evaluation_model do |impulsa_edition|
        link_to impulsa_edition.monitoring_evaluation_model_file_name, impulsa_edition.monitoring_evaluation_model.url if impulsa_edition.monitoring_evaluation_model.exists?
      end
    end

    panel t "activerecord.models.impulsa_edition_categories" do
      table_for resource.impulsa_edition_categories do
        column :name
        column :category_type_name do |impulsa_edition_category|
          t("podemos.impulsa.category_type_name.#{impulsa_edition_category.category_type_name}") if impulsa_edition_category.category_type_name
        end
        column :winners
        column :prize
        column :projects do |impulsa_edition_category|
          "#{impulsa_edition_category.impulsa_projects.first_phase.count} -> &check;#{impulsa_edition_category.impulsa_projects.second_phase.count} (&#9785;#{impulsa_edition_category.impulsa_projects.no_phase.count})".html_safe
        end
        column :actions do |impulsa_edition_category|
          span link_to(t('active_admin.edit'), edit_admin_impulsa_edition_impulsa_edition_category_path(resource, impulsa_edition_category))
          span link_to(t('active_admin.delete'), admin_impulsa_edition_impulsa_edition_category_path(resource, impulsa_edition_category), method: :delete, data: { confirm: "¿Estas segura de querer borrar esta categoría?" })
        end
      end
      div link_to(t('active_admin.has_many_new', model: t("activerecord.models.impulsa_edition_category")), new_admin_impulsa_edition_impulsa_edition_category_path(resource))
    end

    panel t "activerecord.models.impulsa_edition_topics" do
      table_for resource.impulsa_edition_topics do
        column :name
        column :actions do |topic|
          span link_to(t('active_admin.edit'), edit_admin_impulsa_edition_impulsa_edition_topic_path(resource, topic))
          span link_to(t('active_admin.delete'),  admin_impulsa_edition_impulsa_edition_topic_path(resource, topic), method: :delete, data: { confirm: "¿Estas segura de querer borrar esta temática?" })
        end
      end
      div link_to(t('active_admin.has_many_new', model: t("activerecord.models.impulsa_edition_topics")), new_admin_impulsa_edition_impulsa_edition_topic_path(resource))
    end
  end

  form do |f|
    f.inputs "Impulsa edition" do
      f.input :name
      f.input :start_at
      f.input :new_projects_until
      f.input :review_projects_until
      f.input :validation_projects_until
      f.input :ends_at
      I18n.available_locales.each do |locale|
        f.input "legal_#{locale}", label: "#{t("activerecord.attributes.impulsa_edition.legal")} #{I18n.name_for_locale(locale)}"
      end
      f.input :schedule_model, as: :file
      f.input :activities_resources_model, as: :file
      f.input :requested_budget_model, as: :file
      f.input :monitoring_evaluation_model, as: :file
    end
    f.actions
  end

  action_item(:view_projects, only: :show) do
    link_to('Ver proyectos', admin_impulsa_edition_impulsa_projects_path(impulsa_edition))
  end
end

ActiveAdmin.register ImpulsaEditionTopic do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params :impulsa_edition_id, :name

  form do |f|
    f.inputs do
      f.input :impulsa_edition_id, as: :hidden
      li do
        label :impulsa_edition
        div class: :readonly do link_to(resource.impulsa_edition.name, admin_impulsa_edition_path(resource.impulsa_edition)) end
      end
      f.input :name
    end
    f.actions
  end
end
