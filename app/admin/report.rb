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
      @main_group = YAML.load(resource.main_group)
      @groups = YAML.load(resource.groups)
      @results = YAML.load(resource.results)
      @results[:data].each do |main_group, groups|
        panel "#{@main_group.title}: #{main_group}" do
          @groups.each do |group|
            panel group.title do
              table_for @results[:data][main_group][group.id] do
                column group.label, :name
                column "Total" do |r|
                  r[:count]
                end
                column group.data_label do |r|
                  r[:samples].sort_by{|k, v| [-v, k]} .map {|k,v| if v>1 then "#{k}(#{v})" else k end } .join(", ") if r[:samples]
                end
                column :users do |r|
                  r[:users][0..20].map do |u| link_to(u, admin_user_path(u)).html_safe end .join(" ").html_safe if r[:users]
                end
                column :info do |r|
                  status_tag("BLACKLIST", :error) if group.blacklist? r[:name]
                end
              end
            end
          end
        end
      end
    end
  end

  member_action :run do
    Resque.enqueue(PodemosReportWorker, params[:id])
    redirect_to :admin_reports
  end

  action_item only: :show do
    if resource.results.nil?
      link_to 'Generar', run_admin_report_path(id: resource.id)
    else
      link_to 'Regenerar', run_admin_report_path(id: resource.id), data: { confirm: "Se perderán los resultados actuales del informe. ¿Deseas continuar?" }
    end
  end

end
