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

  show do 
    attributes_table do
      row :title
      row :agora_election_id
      row :starts_at
      row :ends_at
      row "Crear Aviso" do
        link_to "Crear aviso para móviles para esta votación", new_admin_notice_path(notice: { link: create_vote_url(election_id: election.agora_election_id), title: "Podemos", body: "Nueva votación disponible: #{election.title}" }), class: "button"
      end
    end
    active_admin_comments
  end

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
