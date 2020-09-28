ActiveAdmin.register VoteCircle do
  DEFAULT_VOTE_CIRCLE = "IP000000001"
  menu :parent => "Users"
  permit_params :original_code, :original_name,:code,:name,:island_code,:town, :vote_circle_autonomy
  sidebar "Añadir Circulos desde fichero", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render('upload_vote_circles')
  end
  sidebar "Descarga Personas de Contacto de Circulos inexistentes, inactivos o en construcción", 'data-panel' => :collapsed, :only => :index, priority: 2 do
    render('contact_people_vote_circles')
  end
  index download_links: -> { current_user.is_admin? && current_user.superadmin? }


  collection_action :upload_vote_circles, :method => :post do
    file_input = params["vote_circles"]["file"].tempfile
    CSV.foreach(file_input, :headers => true, :col_sep=> "\t", encoding: "UTF-8") do |row|
      VoteCircle.create(row.to_hash)
    end
    redirect_to collection_path, notice: "¡Fichero importado correctamente!"
  end

  collection_action :contact_people_vote_circles,:method => :post do
    csv =CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      header =["ccaa","prov","muni","nombre_pila","telefono","email"]
      csv << header

      ccaa = params["vote_circle_autonomy"] unless params["vote_circle_autonomy"].blank?
      ids = VoteCircle.where("code like 'IP%'").pluck(:id)
      users = User.militant.where(vote_circle_id:ids)
      data=[]
      users.each do |u|
        next if ccaa && ccaa != u.autonomy_code
        data.push([u.autonomy_name, u.province_name, u.town_name,u.first_name,u.phone,u.email])
      end
      data.sort_by do |row|
        [row[0], row[1], row[2], row[3], row[4], row[5]]
        csv << row
      end
    end

    if csv.count("\n") > 1
      send_data csv.encode('utf-8'),
                type: 'text/tsv; charset=utf-8; header=present',
                disposition: "attachment; filename=personas_contacto_circulos.#{Date.today.to_s}.csv"
    else
      redirect_to collection_path, flash: {warning: "¡No se han encontrado registros que cumplan esa condición!"}
    end
  end

  controller do
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
