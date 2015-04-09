ActiveAdmin.register Microcredit do
  permit_params :title, :starts_at, :ends_at, :total_goal, :limits, :account_number, :contact_phone, :agreement_link

  index do
    selectable_column
    id_column
    column :title
    column :starts_at
    column :limits do |m|
      m.limits.map do |amount, limit|
        "#{amount}€:&nbsp;#{limit}"
      end .join("<br/>").html_safe
    end
    column :totals do |m|
      (m.phase_status.group_by(&:first).map do |amount, info|
        "#{amount}€:&nbsp;#{info.map {|x| "#{x[3]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.join "&nbsp;"}"
      end + ["------"] + m.campaign_status.group_by(&:first).map do |amount, info|
        "#{amount}€:&nbsp;#{info.map {|x| "#{x[3]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.join "&nbsp;"}"
      end).join("<br/>").html_safe
    end
    column :percentages do |m|
      m.limits.map do |amount, limit|
        "#{amount}€:&nbsp;#{(m.current_percent(amount, false, 0)*100).round(2)}/#{((1-m.ellapsed_time_percent)*100).round(2)}%&nbsp;#{(m.current_percent(amount, true, 0)*100).round(2)}/#{(m.ellapsed_time_percent*100).round(2)}%"
      end .join("<br/>").html_safe
    end
    column :progress do |m|
      "&check;:&nbsp;#{m.campaign_confirmed_amount}/#{m.total_goal}&nbsp;(#{(100.0*m.campaign_confirmed_amount/m.total_goal).round(2)}%)<br/>&oplus;:&nbsp;#{m.campaign_counted_amount}/#{m.total_goal}&nbsp;(#{(100.0*m.campaign_counted_amount/m.total_goal).round(2)}%)".html_safe
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :starts_at
      f.input :ends_at
      f.input :total_goal
      f.input :limits
      f.input :account_number
      f.input :contact_phone
      f.input :agreement_link
    end
    f.actions
  end

  action_item :only => :show do
    link_to('Cambiar de fase', change_phase_admin_microcredit_path(resource), method: :post, data: { confirm: "¿Estas segura de que deseas cambiar de fase en esta campaña?" })
  end

  member_action :change_phase, :method => :post do
    Microcredit.find(params[:id]).change_phase
    flash[:notice] = "La campaña ha cambiado de fase."
    redirect_to action: :show
  end

end
