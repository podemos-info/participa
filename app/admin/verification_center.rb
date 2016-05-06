ActiveAdmin.register Verification::Center do
  menu :parent => "Users"

  permit_params :name, :address, :latitude, :longitude, verification_slots_attributes: [:id, :starts_at, :ends_at, :_destroy]

  filter :name
  filter :address

  show do
    attributes_table do
      row :name
      row :address
      row :latitude, class: "js-verification-map-latitude"
      row :longitude, class: "js-verification-map-longitude"
    end
    panel "Mapa" do
      div id: "js-verification-map", style: "width: 100%; height: 400px"
    end
    active_admin_comments
  end

  sidebar "Horarios", only: :show do
    table_for verification_center.verification_slots do
      column :starts_at
      column :ends_at
    end
  end

  form do |f|
    tabs do
      tab "Localización" do
        f.inputs "Información" do
          f.input :name, required: true
          f.input :address, required: true
          a "Buscar", "#", class: "button", id: "js-verification-map-search", style: "margin: 2em 0 1em 1em; cursor: pointer;"
        end
        panel "Mapa" do
          div id: "js-verification-map-error", class: "flash flash_error hide" do
            "No se ha encontrado esta dirección. Corrigela y busca de nuevo o pon su latitud y longitud y agrega el marcador más abajo."
          end
          div id: "js-verification-map", style: "width: 100%; height: 400px"
        end
        f.inputs "Coordenadas" do
          f.input :latitude, required: true
          f.input :longitude, required: true
        end
      end
      tab "Horarios" do
        f.inputs "Horarios" do
          f.has_many :verification_slots, allow_destroy: true do |slot|
            slot.input :starts_at, required: true, as: :datetime_picker, input_html: {class: "js-datetime-picker"}, local: true
            slot.input :ends_at, required: true, as: :datetime_picker, input_html: {class: "js-datetime-picker"}, local: true
          end
        end
      end
    end
    f.actions
  end

end
