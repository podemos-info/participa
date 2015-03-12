ActiveAdmin.register ReportGroup do
  menu false

  permit_params  :title, :proc, :width, :label, :data_label, :whitelist, :blacklist, :minimum, :minimum_label, :visualization

  index do
    selectable_column
    id_column
    column :title
    column :width
    column :minimum
    column :visualization
    actions
  end
end
