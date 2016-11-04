ActiveAdmin.register Election do
  menu :parent => "Participación"

  permit_params :title, :info_url, :agora_election_id, :scope, :server, :starts_at, :ends_at, :close_message, :locations, :user_created_at_max, :priority, :info_text, :requires_sms_check, :show_on_index, :ignore_multiple_territories, :meta_description, :meta_image

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
  filter :user_created_at_max

  show do 
    attributes_table do
      row :requires_sms_check do
        status_tag("SMS CHECK", :ok)
      end if election.requires_sms_check
      row :show_on_index do
        status_tag("SHOW ON INDEX", :ok)
      end if election.show_on_index
      row :ignore_multiple_territories do
        status_tag("IGNORE MULTIPLE TERRITORIES", :ok)
      end if election.ignore_multiple_territories
      row :title
      row :info_url
      row :info_text
      row :meta_description
      row :meta_image
      row :server
      row :priority
      row :agora_election_id
      row :scope_name
      row :starts_at
      row :ends_at
      row :user_created_at_max
      row :close_message do 
        raw election.close_message
      end
      row "Crear Aviso" do
        link_to "Crear aviso para móviles para esta votación", new_admin_notice_path(notice: { link: create_vote_url(election_id: election.id), title: "Podemos", body: "Nueva votación disponible: #{election.title}" }), class: "button"
      end
    end

    panel "Lugares donde se vota" do
      table_for election.election_locations.order(:location) do
        column :territory
        column :link do |el|
          span link_to el.link, el.link
          br
          span link_to el.new_link, el.new_link if el.new_version_pending
        end
        column :counter do |el|
          span link_to "Contador", election_location_votes_count_path(el.election, el, el.counter_hash)
        end
        column :actions do |el|
          span link_to "Modificar", edit_admin_election_election_location_path(el.election, el)
          span link_to "Borrar", admin_election_election_location_path(el.election, el), method: :delete, data: { confirm: "¿Estas segura de borrar esta ubicación?" }
          span link_to "TSV", download_voting_definition_admin_election_path(el) if el.has_voting_info
          status_tag("VERSION NUEVA", :error) if el.new_version_pending
        end
      end
      
      span link_to "Añadir ubicación", new_admin_election_election_location_path(election)
    end

    panel "Evolución" do
      svg class: "js-election-graph", "data-url" => votes_analysis_admin_election_path(election.id), "data-height"=>700
    end

    active_admin_comments
  end

  member_action :download_voting_definition do
    election_location = ElectionLocation.find(params[:id])
    headers["Content-Type"] ||= 'text/csv'
    headers["Content-Disposition"] = "attachment; filename=\"#{election_location.new_vote_id}.tsv\"" 
    render "election_location.tsv", layout: false, locals: { election_location: election_location }
  end

  member_action :votes_analysis do
    histogram = Election.find(params[:id]).votes_histogram
    render json: histogram
  end

  form do |f|
    f.inputs "Election" do
      f.input :title
      f.input :info_url
      f.input :info_text
      f.input :meta_description, label: "Descripción del sitio para redes sociales durante la votación"
      f.input :meta_image, label: "URL de la imagen del sitio para redes sociales durante la votación"
      f.input :priority
      f.input :server, as: :select, collection: Election.available_servers
      f.input :agora_election_id
      f.input :scope, as: :select, collection: Election::SCOPE
      f.input :locations, as: :text, :input_html => { :class => 'autogrow', :rows => 10, :cols => 10  } if !resource.persisted?
      f.input :starts_at
      f.input :ends_at
      f.input :close_message
      f.input :user_created_at_max
      f.input :requires_sms_check, as: :boolean
      f.input :show_on_index, as: :boolean
      f.input :ignore_multiple_territories, as: :boolean
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
      li "Votos totales: #{election.valid_votes_count}"
      li do
        a "Contador total", href: election_votes_count_path(election, election.counter_hash)
      end
      li "Censo activos: #{election.current_active_census}"
      li "Censo actual: #{election.current_total_census}"
      li "Votos de usuarios baneados: #{election.votes.joins(:user).merge(User.banned).count}"
      li do 
        a 'Descargar voter ids', href: download_voter_ids_admin_election_path(election)
      end
    end
  end
end

ActiveAdmin.register ElectionLocation do
  menu false
  belongs_to :election
  navigation_menu :default
    
  permit_params :election_id, :location, :agora_version, :new_agora_version, :override, :title, :layout, :description, :share_text, :theme, :has_voting_info,
                election_location_questions_attributes: [ :id, :_destroy, :title, :description, :voting_system, :layout, :winners, :minimum, :maximum, :random_order, :totals, :options, options_headers: [] ]

  form partial: "election_location", locals: { spain: Carmen::Country.coded("ES") }

  controller do
    def create
      super do |format|
        redirect_to admin_election_path(resource.election) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_election_path(resource.election) and return if resource.valid?
      end
    end
  end

end
