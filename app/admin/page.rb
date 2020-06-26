ActiveAdmin.register Page do

  permit_params :id_form, :title, :slug, :link, :require_login, :meta_description, :meta_image, :promoted, :priority, :text_button

  action_item(:reload_routes, only: :show) do
    link_to('Recargar rutas', reload_admin_pages_path, data: { confirm: "¿Estas segura de querer recargar las rutas?" })
  end

  collection_action :reload, :method => :get do
    Process.kill('HUP', Process.ppid()) if !Rails.env.development?
    redirect_to collection_path, alert: "Las rutas han sido recargadas."
  end

  index do
    selectable_column
    id_column
    column :title
    column :id_form
    column :slug do |page|
      link_to page.slug, "/#{page.slug}"
    end
    column :require_login
    column :promoted
    column :priority
    actions
  end

  show do
    attributes_table do
      row :title
      row :slug
      row :id_form
      row :link
      row :require_login
      row :meta_description
      row :meta_image
      row :promoted
      row :priority
      row :text_button
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Formulario de gravity' do
      #div "Creado en #{f.object.created_at}" unless f.object.new_record?
      f.input :title, label: "Título de la página"
      f.input :slug, label: "Slug (dirección de la página)", placeholder: "direccion-sin-barra-inicial"
      f.input :id_form, label: "Número de formulario en gravity"
      f.input :link, label: "Enlace a la vista en gravity"
      f.input :require_login, :as => :boolean, label: "Requerir que el usuario se autentifique"
      f.input :meta_description, label: "Descripción de la página para redes sociales"
      f.input :meta_image, label: "URL de la imagen para redes sociales"
      f.input :promoted, :as => :boolean, label: "Visualizar en la página inicial de Participa"
      f.input :priority, label: "Nivel de importancia dentro de la lista. Cuanto mayor es más arriba aparece"
      f.input :text_button, label:"Texto del botón para invitar a entrar al usuario.", default: "Apúntate aquí"
    end
    f.actions
  end

end
