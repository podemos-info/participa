ActiveAdmin.register Collaboration do
  permit_params :amount, :frequency

  index do
    selectable_column
    id_column
    column :user
    column :amount
    column :frequency
    column :created_at
    actions
  end

  filter :user
  filter :amount
  filter :frequency
  filter :created_at

  show do |collaboration|
    attributes_table do 
      row :user
      row :amount do
        number_to_euro collaboration.amount
      end
      row :frequency do
        "cada #{collaboration.frequency} días"
      end
      row :created_at 
      row :updated_at 
      row :order_id do 
        collaboration.order_id
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Collaboration Details" do
      f.input :user #, input_html: {disabled: true}
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS # , input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES #, input_html: {disabled: true}
    end
    f.actions
  end

end
