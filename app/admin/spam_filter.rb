ActiveAdmin.register SpamFilter do
  menu :parent => "Users"

  permit_params :name, :code, :data, :query, :active

  member_action :test do
    id = params[:id]
    filter = SpamFilter.find(id)
    users = filter.test
    html = Arbre::Context.new({}, self) do
      h2 "Usuarios afectados: #{users.count}"
      div do
        users.each do |u|
          a u, href:admin_user_path(u)
        end
      end
      a 'Volver', href:admin_spam_filter_path(id: id)
    end

    render inline: html.to_s, layout: true
  end

  action_item only: :show do
    link_to 'Probar', test_admin_spam_filter_path(id: resource.id)    
  end


end
