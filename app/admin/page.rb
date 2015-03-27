ActiveAdmin.register Page, as: "Formulario" do

  permit_params :id_form, :title, :slug, :require_login

  form do |f|
    f.semantic_errors
    f.inputs 'Formulario de gravity' do
      #div "Creado en #{f.object.created_at}" unless f.object.new_record?
      f.input :title, label: "Título de la página"
      f.input :slug, label: "Slug (dirección de la página)", placeholder: "direccion-sin-barra-inicial"
      f.input :id_form, label: "Número de formulario en gravity"
      f.input :require_login, :as => :boolean, label: "Requerir que el usuario se autentifique"
    end
    f.actions
  end

end
