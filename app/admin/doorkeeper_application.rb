ActiveAdmin.register Doorkeeper::Application, as: "Application" do

  permit_params :name, :redirect_uri, :scopes

  menu parent: "Users", label:->{ I18n.t "doorkeeper.layouts.admin.nav.applications" }
  config.comments = false

  index do
    selectable_column
    id_column
    column :name
    column :uid
    column :secret
    column :redirect_uri
    column :scopes
    column :created_at
    actions
  end

  filter :name

  form do |f|
    f.inputs do
      f.input :name
      f.input :redirect_uri, as: :string
      f.input :scopes
    end
    f.actions
  end

end
