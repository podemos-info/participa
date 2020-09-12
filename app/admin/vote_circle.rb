ActiveAdmin.register VoteCircle do
  menu :parent => "Users"
  #permit_params :original_code, :original_name
  sidebar "Añadir Circulos desde fichero", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render('upload_vote_circles')
  end
  index download_links: -> { current_user.is_admin? && current_user.superadmin? }


  collection_action :upload_vote_circles, :method => :post do
    file_input = params["vote_circles"]["file"].tempfile
    CSV.foreach(file_input, :headers => true, :col_sep=> "\t", encoding: "UTF-8") do |row|
      VoteCircle.create(row.to_hash)
    end
    redirect_to collection_path, notice: "¡Fichero importado correctamente!"
  end

  controller do
    DEFAULT_VOTE_CIRCLE = "IP000000001"

    before_destroy :change_children_vote_circle

    def change_children_vote_circle(resource)
      default_id = VoteCircle.where(code: DEFAULT_VOTE_CIRCLE).pluck(:id).first

      users = User.where(vote_circle_id:default_id)
      users.each do |u|
        u.update(vote_circle_id: default_id)
      end
    end
  end

end
