ActiveAdmin.register ImpulsaEdition do
  menu :parent => "Participación"
  config.filters = false
  permit_params :id, :name, :email, :description, :start_at, :new_projects_until, :review_projects_until, :validation_projects_until, :votings_start_at, :ends_at, :publish_results_at

  index do
    selectable_column
    id_column
    column :name
    column :start_at
    column :new_projects_until
    column :review_projects_until
    column :validation_projects_until
    column :votings_start_at
    column :ends_at
    column :publish_results_at
    column "Proyectos" do |impulsa_edition|
      link_to("Mostrar #{impulsa_edition.impulsa_projects.count} proyectos", admin_impulsa_edition_impulsa_projects_path(impulsa_edition))
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :description
      row :start_at
      row :new_projects_until
      row :review_projects_until
      row :validation_projects_until
      row :votings_start_at
      row :ends_at
      row :publish_results_at
    end

    panel t "activerecord.models.impulsa_edition_categories" do
      table_for resource.impulsa_edition_categories.order(:name) do
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
      f.input :email
      f.input :description
      f.input :start_at
      f.input :new_projects_until
      f.input :review_projects_until
      f.input :validation_projects_until
      f.input :votings_start_at
      f.input :ends_at
      f.input :publish_results_at
    end
    f.actions
  end

  action_item(:view_projects, only: :show) do
    link_to('Ver proyectos', admin_impulsa_edition_impulsa_projects_path(impulsa_edition))
  end

  action_item(:create_election, only: :show) do
    link_to('Crear votaciones', create_election_admin_impulsa_edition_path(impulsa_edition), data: { confirm: "¿Estas segura de querer crear las votaciones para esta edición de IMPULSA?" })
  end

  member_action :create_election do
    p = ImpulsaEdition.find( params[:id] )  
    if p.create_election request.base_url
      flash[:notice] = "Se han creado las votaciones para la edición de IMPULSA."
    else
      flash[:error] = "Las votaciones para la edición de IMPULSA no se han creado."
    end
    redirect_to action: :index
  end

end

ActiveAdmin.register ImpulsaEditionTopic do
  navigation_menu :default
  menu false
  belongs_to :impulsa_edition, optional: true


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
