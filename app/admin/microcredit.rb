ActiveAdmin.register Microcredit do
  config.sort_order = 'title_asc'
  
  scope :all
  scope :active
  scope :upcoming_finished
  
  index do
    selectable_column
    id_column
    column :title
    column :dates do |m|
      "#{m.starts_at}<br/>#{m.ends_at}".html_safe
    end
    column :limits do |m|
      ([ "<strong>Total&nbsp;fase:&nbsp;#{number_to_euro(m.phase_limit_amount*100, 0)}</strong>" ] + m.limits.map do |amount, limit|
        "#{number_to_euro amount*100, 0}:&nbsp;#{limit}"
      end).join("<br/>").html_safe
    end
    column :totals, text_align:"right" do |m|
      (m.phase_status.group_by(&:first).map do |amount, info|
        "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[3]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
      end + ["------"] + m.campaign_status.group_by(&:first).map do |amount, info|
        "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[3]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
      end).join("<br/>").html_safe
    end
    column :percentages do |m|
      ([ "<strong>Confianza:&nbsp;#{(m.remaining_percent*100).round(2)}%</strong>" ] + m.limits.map do |amount, limit|
        "#{number_to_euro amount*100, 0}:&nbsp;#{(m.current_percent(amount, false, 0)*100).round(2)}%"
      end).join("<br/>").html_safe
    end
    column :progress do |m|
      ["<strong>Total: #{number_to_euro m.total_goal*100, 0}</strong>",
        "&cross;:&nbsp;#{number_to_euro(m.campaign_unconfirmed_amount*100, 0)}&nbsp;(#{(100.0*m.campaign_unconfirmed_amount/m.total_goal).round(2)}%)",
        "&check;:&nbsp;#{number_to_euro(m.campaign_confirmed_amount*100, 0)}&nbsp;(#{(100.0*m.campaign_confirmed_amount/m.total_goal).round(2)}%)",
        "&ominus;:&nbsp;#{number_to_euro(m.campaign_not_counted_amount*100, 0)}&nbsp;(#{(100.0*m.campaign_not_counted_amount/m.total_goal).round(2)}%)",
        "&oplus;:&nbsp;#{number_to_euro(m.campaign_counted_amount*100, 0)}&nbsp;(#{(100.0*m.campaign_counted_amount/m.total_goal).round(2)}%)"].join("<br/>").html_safe
    end
    actions
  end

  form do |f|
    f.inputs do
      if can? :admin, Microcredit
        f.input :title
        f.input :starts_at
        f.input :ends_at
        f.input :limits
        f.input :account_number
        f.input :agreement_link
        f.input :total_goal, step: 100
      else
        f.inputs "Importes de los microcréditos" do
          f.input :phase_limit_amount, label: "Total por fase", input_html: { disabled: true }
          f.object.limits.each do |amount, limit|
            f.input "single_limit_#{amount}", label: "#{number_to_euro amount*100, 0}", as: :number, min: f.object.phase_current_for_amount(amount), input_html: { class: "single_limits", data: { amount: amount } }
          end
        end
      end
      f.input :contact_phone
    end
    f.actions
  end

  show do
    panel "Evolución" do
      render "admin/microcredits_history"
    end
  end

  filter :starts_at
  filter :ends_at
  
  sidebar "Ayuda", only: :index, priority: 0 do
    para "Para compensar el retraso en la confirmación de los ingresos, al inicio de la campaña se muestran en la web suscripciones no confirmadas."
    para "La confianza en que los ingresos van a ser confirmados decrece progresivamente a medida que pasa el tiempo y que se reciben más suscripciones, para evitar que al finalizar la campaña el total que aparece en la web supere el total efectivamente recibido."
    ul do
      li "&cross; = suscrito".html_safe
      li "&check; = confirmado".html_safe
      li "&ominus; = NO se ve en la web".html_safe
      li "&oplus; = visible en la web".html_safe
    end
  end

  sidebar "Estadísticas últimas campañas", only: :index, priority: 0 do
    ul do
      li "Objetivo: #{number_to_euro Microcredit.total_current_amount*100}"
      li "Suscritos: #{number_to_euro MicrocreditLoan.total_current*100} (#{MicrocreditLoan.upcoming_finished.count})"
      li "Visibles: #{number_to_euro MicrocreditLoan.total_counted_current*100} (#{MicrocreditLoan.upcoming_finished.counted.count})"
      li "Confirmados: #{number_to_euro MicrocreditLoan.total_confirmed_current*100} (#{MicrocreditLoan.upcoming_finished.confirmed.count})"      
    end
  end

  action_item :only => :show do
    link_to('Cambiar de fase', change_phase_admin_microcredit_path(resource), method: :post, data: { confirm: "¿Estas segura de que deseas cambiar de fase en esta campaña?" })
  end

  member_action :change_phase, :method => :post do
    Microcredit.find(params[:id]).change_phase
    flash[:notice] = "La campaña ha cambiado de fase."
    redirect_to action: :show
  end

  controller do
    def update
      if can? :admin, Microcredit
        super
      else
        resource.limits = params[:microcredit].map {|k,v| "#{k[13..-1]} #{v.to_i} " if k.start_with?("single_limit_") } .join ""
        super
      end
    end
  end

  permit_params do
    if can? :admin, Microcredit
      [:title, :starts_at, :ends_at, :limits, :account_number, :total_goal, :contact_phone, :agreement_link]
    else
      [:contact_phone]
    end
  end

end
