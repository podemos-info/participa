ActiveAdmin.register ImpulsaEditionCategory do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params :impulsa_edition_id, :name, :has_votings, :category_type, :winners, :prize, :only_authors, :coofficial_language, :wizard_raw, :evaluation_raw, territories: []

  show do
    attributes_table do
      row :impulsa_edition
      row :name
      row :category_type_name do |impulsa_edition_category|
        t("podemos.impulsa.category_type_name.#{impulsa_edition_category.category_type_name}") if impulsa_edition_category.category_type_name
      end
      row :winners
      row :prize
      row :only_authors
      row :coofficial_language_name
      row :territories do |impulsa_edition_category|
        impulsa_edition_category.territories_names.join ", "
      end
      row :info do
        all_fields = impulsa_edition_category.wizard.map do |sname,step| 
          step[:groups].map do |gname,group|
            group[:fields].map do |fname,field|
              "#{gname}.#{fname}"
            end
          end
        end .flatten
        status_tag("Campos duplicados", :warn) if all_fields.count > all_fields.uniq.count
        status_tag("Votacion", :ok) if impulsa_edition_category.has_votings
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :impulsa_edition_id, as: :hidden
      li do
        label :impulsa_edition
        div class: :readonly do 
          link_to(resource.impulsa_edition.name, admin_impulsa_edition_path(resource.impulsa_edition)) 
        end
      end
      f.input :name
      f.input :category_type, as: :select, collection: ImpulsaEditionCategory::CATEGORY_TYPES.map{|k,v| [I18n.t("podemos.impulsa.category_type_name.#{k}"), v]}
      f.input :winners, min: 1
      f.input :prize, min: 0
      f.input :has_votings, as: :boolean
      f.input :only_authors
      f.input :coofficial_language, as: :select, collection: I18n.available_locales.map {|l| [I18n.name_for_locale(l),l] if l!=I18n.default_locale }
      f.input :territories, as: :check_boxes, collection: Podemos::GeoExtra::AUTONOMIES.values.uniq.map(&:reverse).sort if resource.has_territory?
      f.input :wizard_raw, as: :text, input_html: { rows: 30, class: "yaml" }
      f.input :evaluation_raw, as: :text, input_html: { rows: 30, class: "yaml" }
    end
    f.actions
  end
end
