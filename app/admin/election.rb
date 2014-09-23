ActiveAdmin.register Election do

  permit_params :title, :agora_election_id, :starts_at, :ends_at

  index do
    selectable_column
    id_column
    column :title
    column :agora_election_id
    column :starts_at
    column :ends_at
    actions
  end

  filter :title
  filter :agora_election_id

  form do |f|
    f.inputs "Election" do
      f.input :title
      f.input :agora_election_id
      f.input :starts_at
      f.input :ends_at
    end
    f.actions
  end
end
