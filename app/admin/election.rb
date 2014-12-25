ActiveAdmin.register Election do

  permit_params :title, :agora_election_id, :scope, :starts_at, :ends_at, :close_message, :locations

  index do
    selectable_column
    id_column
    column :title
    column :agora_election_id
    column :scope_name
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
      row :scope_name
      row :starts_at
      row :ends_at
      row :close_message do 
        raw election.close_message
      end
      row "Crear Aviso" do
        link_to "Crear aviso para móviles para esta votación", new_admin_notice_path(notice: { link: create_vote_url(election_id: election.id), title: "Podemos", body: "Nueva votación disponible: #{election.title}" }), class: "button"
      end
      if election.scope != 0 
        row "Lugares donde se vota" do
          election.election_locations.each do |loc|
            li loc.location
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Election" do
      f.input :title
      f.input :agora_election_id
      f.input :scope, as: :select, collection: Election::SCOPE
      f.input :locations, as: :text, :input_html => { :class => 'autogrow', :rows => 10, :cols => 10  }
      f.input :starts_at
      f.input :ends_at
      f.input :close_message
    end
    f.actions
  end
end
