ActiveAdmin.register Page do

  permit_params :id_form, :title, :slug, :link, :require_login

  action_item(:show) do
    link_to('Recargar rutas', reload_admin_pages_path, data: { confirm: "¿Estas segura de querer recargar las rutas?" })
  end

  collection_action :reload, :method => :get do
    Process.kill('HUP', Process.ppid()) if !Rails.env.development?
    redirect_to collection_path, alert: "Las rutas han sido recargadas."
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
    end
    f.actions
  end

end
