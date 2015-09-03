ActiveAdmin.register ImpulsaEdition do
  menu :parent => "Participación"
  config.filters = false
  permit_params :id, :name, :start_at, :new_projects_until, :review_projects_until, :validation_projects_until, :ends_at, :legal, :schedule_model, :activities_resources_model, :requested_budget_model, :monitoring_evaluation_model

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
        link_to impulsa_edition.legal_file_name, impulsa_edition.legal.url if impulsa_edition.legal.exists?
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

    panel "Categories" do
      table_for resource.impulsa_edition_categories do
        column :name
        column :type_name
        column :winners
        column :prize
        column :actions do |category|
          span link_to('Edit', edit_admin_impulsa_edition_impulsa_edition_category_path(resource, category))
          span link_to('Delete',  admin_impulsa_edition_impulsa_edition_category_path(resource, category), method: :delete)
          span link_to('Ver proyectos', admin_impulsa_edition_category_impulsa_projects_path(category))
        end
      end
      div link_to('Add category', new_admin_impulsa_edition_impulsa_edition_category_path(resource))
    end
  end

  form do |f|
    f.inputs "Impulsa edition" do
      f.input :name
      f.input :start_at, as: :datepicker
      f.input :new_projects_until, as: :datepicker
      f.input :review_projects_until, as: :datepicker
      f.input :validation_projects_until, as: :datepicker
      f.input :ends_at, as: :datepicker
      f.input :legal, as: :file
      f.input :schedule_model, as: :file
      f.input :activities_resources_model, as: :file
      f.input :requested_budget_model, as: :file
      f.input :monitoring_evaluation_model, as: :file
    end
    f.actions
  end
end
