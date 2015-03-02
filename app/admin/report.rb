ActiveAdmin.register Report do
  menu false

  permit_params  :title, :query, :main_group, :groups

  index do
    selectable_column
    id_column
    column :title
    column :query
    actions
  end

end
