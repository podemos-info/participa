ActiveAdmin.register Circle do
  menu :parent => "Users"
  #permit_params :original_code, :original_name
  sidebar "Añadir Circulos desde fichero", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render('upload_circles')
  end
  index download_links: -> { current_user.is_admin? && current_user.superadmin? }


  collection_action :upload_circles, :method => :post do
    file_input = params["circles"]["file"].tempfile
    CSV.foreach(file_input, :headers => true, :col_sep=> "\t", encoding: "UTF-8") do |row|
      Circle.create(row.to_hash)
    end
    redirect_to collection_path, notice: "¡Fichero importado correctamente!"
  end
end
