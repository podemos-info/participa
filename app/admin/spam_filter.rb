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

  action_item(:show) do
    link_to 'Ejecutar', run_admin_spam_filter_path(id: resource.id)
  end

  member_action :run do
    id = params[:id]
    filter = SpamFilter.find(id)
    html = Arbre::Context.new({}, self) do
      h2 "Filtro anti-spam: #{filter.name}"

      para do
        span "Progreso:"
        span id: "js-spam-filter-progress" do text_node "0" end
        span "/"
        span id: "js-spam-filter-total" do text_node filter.query_count.to_s end
      end

      h3 "Usuarios afectados"
      para id:"js-spam-filter-users"
      a 'Volver', class:"button", href:admin_spam_filter_path(id: id)
    end

    render inline: html.to_s, layout: true
  end

  member_action :more do
    id = params[:id]
    offset = params[:offset]
    limit = params[:limit]
    filter = SpamFilter.find(id)
    users = filter.run offset, limit
    html = Arbre::Context.new({}, self) do
      users.each do |u|
        para do
          a u.full_name, href:admin_user_path(u)
          span " - #{u.email} - #{u.phone} - #{u.vote_town_name} (#{u.vote_autonomy_name})"
        end
      end
      if users.length>0
        para do
          a 'Banear bloque',  href: ban_admin_spam_filter_path(id: id, users: users, data: {confirm:"¿Estas segura de querer banear a estos usuarios?"})
        end
      end
    end
    render inline: html.to_s
  end

  member_action :ban do
    id = params[:id]
    users = params[:users]

    filter = SpamFilter.find(id)
    User.ban_users(users, true)
    User.where(id:users).each do |user|
      ActiveAdmin::Comment.create(author:current_user,resource:user,namespace:'admin',body:"Usuario baneado en bloque por el filtro: #{filter.name}")
    end
    redirect_to admin_spam_filter_path(id: id)
  end
end
