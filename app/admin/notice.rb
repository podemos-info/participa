ActiveAdmin.register Notice do
  permit_params :title, :body, :created_at

  index do
    selectable_column
    id_column
    column :title
    column :created_at
    actions
  end

  filter :title
  filter :created_at

  form do |f|
    f.inputs "Notification" do
      f.input :title
      f.input :body
    end
    f.actions
  end

end
