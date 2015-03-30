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

  action_item only: :show do
    link_to 'Prueba rápida', test_admin_spam_filter_path(id: resource.id, full: false)
  end

  action_item only: :show do
    link_to 'Ejecutar', test_admin_spam_filter_path(id: resource.id, full: true)
  end

  TEST_MAX_USERS = 10000
  TEST_MAX_MATCHES = 1000
  member_action :test do
    id = params[:id]
    full = params[:full]=="true"
    filter = SpamFilter.find(id)
    if full
      users = filter.test User.count, User.count
    else
      users = filter.test TEST_MAX_USERS, TEST_MAX_MATCHES
    end
    html = Arbre::Context.new({}, self) do
      if full
        h2 "Usuarios afectados: #{users.count}"
      else
        h2 "Usuarios afectados: #{users.count} - #{users.count*100/User.count}% (#{[TEST_MAX_USERS,User.count].min} tomados aleatoriamente de #{User.count})"
      end
      div do
        users.first(TEST_MAX_MATCHES).each do |u|
          a u, href:admin_user_path(u)
        end
        para "... y #{users.length-TEST_MAX_MATCHES} más" if users.length>TEST_MAX_MATCHES
      end
      if users.length>0
        a 'Banear', href:ban_admin_spam_filter_path(id: id, ids: users, data: {confirm:"¿Estas segura de querer banear a estos usuarios?"})
      end
      a 'Volver', href:admin_spam_filter_path(id: id)
    end

    render inline: html.to_s, layout: true
  end

  member_action :ban do
    id = params[:id]
    ids = params[:ids]
    User.ban_users(ids, true)
    redirect_to admin_spam_filter_path(id: id)
  end
end
