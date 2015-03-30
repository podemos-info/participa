ActiveAdmin.register SpamFilter do
  menu :parent => "Users"

  permit_params :name, :code, :data, :query, :active

  index do
    selectable_column
    id_column
    column :name
    column :code
    column :data do |filter|
      (filter.data.split("\r\n")[0..1].join("<br>") + "<br>...").html_safe
    end
    column :active
    actions
  end

  member_action :test do
    id = params[:id]
    filter = SpamFilter.find(id)
    users = filter.test 50000, 1000
    html = Arbre::Context.new({}, self) do
      h2 "Usuarios afectados: #{users.count} - #{users.count*100/User.count}% (#{[50000,User.count].min} tomados aleatoriamente de #{User.count})"
      div do
        users.each do |u|
          a u, href:admin_user_path(u)
        end
      end
      a 'Repetir prueba', href:test_admin_spam_filter_path(id: id)
      a 'Volver', href:admin_spam_filter_path(id: id)
    end

    render inline: html.to_s, layout: true
  end

  action_item only: :show do
    link_to 'Probar', test_admin_spam_filter_path(id: resource.id)    
  end


end
