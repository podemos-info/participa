ActiveAdmin.register ImpulsaEditionCategory do
  menu false
  belongs_to :impulsa_edition
  navigation_menu :default

  permit_params :impulsa_edition_id, :name, :category_type, :winners, :prize, :territories

  form do |f|
    f.inputs do
      f.input :impulsa_edition_id, as: :hidden
      li do
        label :impulsa_edition
        div class: :readonly do link_to(resource.impulsa_edition.name, admin_impulsa_edition_path(resource.impulsa_edition)) end
      end
      f.input :name
      f.input :category_type, as: :select, collection: ImpulsaEditionCategory::CATEGORY_TYPES.to_a
      f.input :winners, min: 1
      f.input :prize, min: 0
      f.input :territories, as: :check_boxes, collection: Podemos::GeoExtra::AUTONOMIES.values.uniq.map(&:reverse) if resource.has_territory?
    end
    f.actions
  end
end
