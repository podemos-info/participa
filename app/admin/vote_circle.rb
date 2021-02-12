ActiveAdmin.register VoteCircle do
  DEFAULT_VOTE_CIRCLE = "IP000000001"
  menu :parent => "Users"
  permit_params :original_code, :original_name,:code,:name,:island_code,:town, :vote_circle_autonomy, :circle_type
  sidebar "Añadir Circulos desde fichero", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render('upload_vote_circles')
  end
  sidebar "Contacto con personas en círculos inexistentes o en construcción", 'data-panel' => :collapsed, :only => :index, priority: 2 do
    render('contact_people_vote_circles')
  end
  sidebar "Descarga Personas de Contacto de círculos con menos de 5 miembros", 'data-panel' => :collapsed, :only => :index, priority: 3 do
    render('people_in_tiny_vote_circles')
  end
  filter :original_name
  filter :original_code
  filter :created_at
  filter :updated_at
  filter :code
  filter :name
  filter :island_code
  filter :town
  filter :vote_circle_autonomy_id_in, as: :select, collection: Podemos::GeoExtra::AUTONOMIES.values.uniq.map(&:reverse).map{|c| [c[0],"__#{c[1][2,2]}%"]}, label: "Circle autonomy"
  filter :vote_circle_province_id_in, as: :select, collection: Carmen::Country.coded("ES").subregions.map{|x|[x.name, "____#{(x.index).to_s.rjust(2,"0")}%"]}, label: "Circle province"

  index download_links: -> { current_user.is_admin? && current_user.superadmin? }

  form do |f|
    f.semantic_errors
    circle_type = :original_code.present? ? resource.get_type_circle_from_original_code : "TM"
    f.inputs 'Details' do
      input :circle_type, as: :select, collection: [['Comarcal','TC'], ['Municipal','TM'], ['Barrial','TB'], ['Exterior','00']], selected: circle_type, include_blank: false
      input :original_name
      label "Dejar en blanco el código para que se calcule automáticamente"
      input :original_code
      input :name
      input :island_code
      input :region_area_id
      input :town
    end
    f.actions
  end

  collection_action :upload_vote_circles, :method => :post do
    file_input = params["vote_circles"]["file"].tempfile
    CSV.foreach(file_input, :headers => true, :col_sep=> "\t", encoding: "UTF-8") do |row|
      VoteCircle.create(row.to_hash)
    end
    redirect_to collection_path, notice: "¡Fichero importado correctamente!"
  end

  collection_action :contact_people_vote_circles,:method => :post do
    csv =CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      header =["ccaa","prov","muni","nombre_pila","telefono","email","opcion_elegida"]
      csv << header

      ccaa = params["vote_circle_autonomy"] unless params["vote_circle_autonomy"].blank?
      ids = VoteCircle.where("code like 'IP%'").pluck(:id)
      users = User.militant.where(vote_circle_id:ids)
      data=[]
      users.each do |u|
        next if ccaa && ccaa != u.autonomy_code
        data.push([u.autonomy_name, u.province_name, u.town_name,u.first_name,u.phone,u.email,u.vote_circle.name])
      end
      data2 = data.sort_by { |row| [row[6], row[0], row[1], row[2], row[3], row[4], row[5]] }
      data2.each do |row|
        csv << row
      end
    end

    if csv.count("\n") > 1
      send_data csv.encode('utf-8'),
                type: 'text/tsv; charset=utf-8; header=present',
                disposition: "attachment; filename=personas_contacto_circulos_#{}.#{Date.today.to_s}.csv"
    else
      redirect_to collection_path, flash: {warning: "¡No se han encontrado registros que cumplan esa condición!"}
    end
  end

  collection_action :people_in_tiny_vote_circles,:method => :post do
    csv =CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      header =["ccaa","prov","muni","círculo","nombre_pila","telefono","email"]
      csv << header
      data = []
      max_users = 5
      internal_ids = VoteCircle.where("code like 'IP%'").pluck(:id)
      vote_circles = User.militant.where.not(vote_circle_id:nil).where.not(vote_circle_id:internal_ids).group(:vote_circle_id).count(:id)
      ids = vote_circles.select {|k,v| v < max_users}.keys
      users = User.militant.where(vote_circle_id:ids)
      users.find_each do |u|
        data.push([u.autonomy_name, u.province_name, u.town_name,u.vote_circle.name,u.first_name,u.phone,u.email])
      end
      data2 = data.sort_by { |row| [row[0], row[1], row[2], row[3], row[4], row[5],row[6]] }
      data2.each do |row|
        csv << row
      end
    end

    if csv.count("\n") > 1
      send_data csv.encode('utf-8'),
                type: 'text/tsv; charset=utf-8; header=present',
                disposition: "attachment; filename=personas_circulos_minis#{}.#{Date.today.to_s}.csv"
    else
      redirect_to collection_path, flash: {warning: "¡No se han encontrado registros que cumplan esa condición!"}
    end
  end

  controller do
    before_save :before_save
    before_destroy :change_children_vote_circle

    def before_save(resource)
      circle_type = params["vote_circle"]["circle_type"]
      if circle_type == "00"
        resource.code = resource.original_code
      else
        resource.code = resource.get_code_circle resource.town,circle_type unless resource.code.present?
        resource.original_code = resource.code if resource.original_code.strip.empty?
      end
    end

    def change_children_vote_circle(resource)
      default_id = VoteCircle.where(code: DEFAULT_VOTE_CIRCLE).pluck(:id).first

      users = User.where(vote_circle_id:default_id)
      users.each do |u|
        u.update(vote_circle_id: default_id)
      end
    end
  end

end
