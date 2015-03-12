ActiveAdmin.register Proposal do

  controller do
    def scoped_collection
      super.reddit
    end
  end

  permit_params :title, :description, :image_url

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  filter :title

  show do 
    attributes_table do
      row :title
      row :description do
        simple_format(proposal.description)
      end
      row :image_url
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Election" do
      f.input :title
      f.input :description
      f.input :image_url
    end
    f.actions
  end
  
end
