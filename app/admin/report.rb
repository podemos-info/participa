ActiveAdmin.register Report do
  menu false

  permit_params  :title, :query, :main_group, :groups


  index do
    selectable_column
    id_column
    column :title
    column :query
    column :date do |report|
      report.updated_at
    end
    actions
  end

  show do
    if resource.results
      @groups = YAML.load(resource.groups)
      @results = YAML.load(resource.results)
      @groups.each do |group|
        panel group.title do
          data = @results[:data][group.id].select {|x| !group.whitelist? x[:name]}
          table_for data do
            column group.label, :name
            column "Total" do |r|
              r[:count]
            end
            column group.data_label do |r|
              r[:samples].join(", ")  if r[:samples]
            end
            column :users do |r|
              r[:users][0..20].map do |u| link_to(u, admin_user_path(u)).html_safe end .join(" ").html_safe if r[:users]
            end
          end
        end
      end
    end
  end

end
