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
      @main_group = YAML.load(resource.main_group) if resource.main_group
      @groups = YAML.load(resource.groups)
      @results = YAML.load(resource.results)

      block = Proc.new do |main_group|
        @groups.each do |group|
          panel group.title, 'data-panel' => :collapsed do
            table_for @results[:data][main_group][group.id] do
              column group.label do |r|
                div r[:name]
              end
              column "Total" do |r|
                div r[:count]
              end
              column group.data_label do |r|
                div(r[:samples].sort_by{|k, v| [-v, k]} .map {|k,v| if v>1 then "#{k}(#{if v>200 then "200+" else v end})" else k end } .join(", ")) if r[:samples]
              end
              column :users do |r|
                div(r[:users][0..20].map do |u| link_to(u, admin_user_path(u)).html_safe end .join(" ").html_safe) if r[:users]
              end
              column do |r|
                div status_tag("BLACKLIST", :error) if group.blacklist? r[:name]
              end
            end
          end
        end
      end

      if @main_group
        @results[:data].each do |main_group, groups|
          panel "#{@main_group.title}: #{main_group}", 'data-panel' => :collapsed do
            block.call main_group
          end
        end
      else
        block.call nil
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
