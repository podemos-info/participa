ActiveAdmin.register Election do
  menu :parent => "Participación"

  permit_params :title, :info_url, :agora_election_id, :scope, :server, :starts_at, :ends_at, :close_message, :locations

  index do
    selectable_column
    id_column
    column :title
    column :server
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
      row :info_url
      row :server
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
            li "#{loc.location},#{loc.agora_version}"
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Election" do
      f.input :title
      f.input :info_url
      f.input :server, as: :select, collection: Election.available_servers
      f.input :agora_election_id
      f.input :scope, as: :select, collection: Election::SCOPE
      f.input :locations, as: :text, :input_html => { :class => 'autogrow', :rows => 10, :cols => 10  }
      f.input :starts_at
      f.input :ends_at
      f.input :close_message
    end
    f.actions
  end

  member_action :download_voter_ids do
    election_id = params[:id]
    csv = CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      prev_user_id = nil
      Vote.joins(:user).merge!(User.confirmed.not_banned).where(election_id: election_id).select(:user_id, :voter_id).order(user_id: :asc, created_at: :desc).each do |vote| 
        csv << [ vote.voter_id ] if prev_user_id != vote.user_id
        prev_user_id = vote.user_id
      end
    end
    send_data csv.encode('utf-8'),
      type: 'text/tsv; charset=utf-8; header=present',
      disposition: "attachment; filename=voter_ids.#{election_id}.tsv"
  end

  sidebar "Progreso", only: :show, priority: 0 do
    ul do
      li "Votos totales: #{election.votes.count}"
      li "Votos de usuarios baneados: #{election.votes.joins(:user).merge(User.banned).count}"
      a 'Descargar voter ids', href: download_voter_ids_admin_election_path(election)
    end
  end
end
