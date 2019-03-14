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
        "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[4]}#{x[3] ? '&#9785;' : (x[1] ? '&check;' : '&cross;')}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
      end + ["------"] + m.campaign_status.group_by(&:first).map do |amount, info|
        "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[4]}#{x[3] ? '&#9785;' : (x[1] ? '&check;' : '&cross;')}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
      end).join("<br/>").html_safe
    end
    column :percentages do |m|
      ([ "<strong>Confianza:&nbsp;#{(m.remaining_percent*100).round(2)}%</strong>" ] + m.limits.map do |amount, limit|
        "#{number_to_euro amount*100, 0}:&nbsp;#{(m.current_percent(amount)*100).round(2)}%"
      end).join("<br/>").html_safe
    end
    column :progress do |m|
        ["<strong>Objetivo: #{number_to_euro m.total_goal*100, 0}",
          "#{m.campaign_created_count}:&nbsp;#{number_to_euro(m.campaign_created_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_created_amount/m.total_goal, precision:2)})</strong>",
          "#{m.campaign_confirmed_count}&check;:&nbsp;#{number_to_euro(m.campaign_confirmed_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_confirmed_amount/m.campaign_created_amount, precision:2)})",
          "#{m.campaign_unconfirmed_count}&cross;:&nbsp;#{number_to_euro(m.campaign_unconfirmed_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_unconfirmed_amount/m.campaign_created_amount, precision:2)})",
          "#{m.campaign_counted_count}&oplus;:&nbsp;#{number_to_euro(m.campaign_counted_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_counted_amount/m.campaign_created_amount, precision:2)})",
          "#{m.campaign_not_counted_count}&ominus;:&nbsp;#{number_to_euro(m.campaign_not_counted_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_not_counted_amount/m.campaign_created_amount, precision:2)})",
          "#{m.campaign_discarded_count}&#9785;:&nbsp;#{number_to_euro(m.campaign_discarded_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*m.campaign_discarded_amount/m.campaign_created_amount, precision:2)})"
          ].join("<br/>").html_safe
    end
    actions
  end

  form do |f|
    f.inputs do
      f.semantic_errors *f.object.errors.keys
      if can? :admin, Microcredit
        f.input :title
        f.input :priority
        f.input :starts_at
        f.input :ends_at
        f.input :limits
        f.input :subgoals
        f.input :account_number
        f.input :agreement_link
        f.input :budget_link
        f.input :renewal_terms, as: :file
        f.input :total_goal, step: 100
        f.input :bank_counted_amount
        f.input :mailing, as: :boolean
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
    attributes_table do
      row :id
      row :title
      row :priority
      row :slug
      row :starts_at
      row :ends_at
      row :account_number
      row :agreement_link
      row :budget_link
      row :renewal_terms do |microcredit|
        link_to(microcredit.renewal_terms_file_name, microcredit.renewal_terms.url) if microcredit.renewal_terms.exists?
      end
      row :total_goal
      row :bank_counted_amount
      row :limits do
        ([ "<strong>Total&nbsp;fase:&nbsp;#{number_to_euro(microcredit.phase_limit_amount*100, 0)}</strong>" ] + microcredit.limits.map do |amount, limit|
        "#{number_to_euro amount*100, 0}:&nbsp;#{limit}"
        end).join("<br/>").html_safe
      end
      row :totals do
        (microcredit.phase_status.group_by(&:first).map do |amount, info|
          "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[4]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
        end + ["------"] + microcredit.campaign_status.group_by(&:first).map do |amount, info|
          "#{number_to_euro amount*100, 0}:&nbsp;#{info.map {|x| "#{x[4]}#{x[1] ? '&check;' : '&cross;'}#{x[2] ? '&oplus;' : '&ominus;'}"}.sort{|a,b| a.gsub(/\d/,"")<=>b.gsub(/\d/,"")}.join "&nbsp;"}"
        end).join("<br/>").html_safe
      end
      row :percentages do
        ([ "<strong>Confianza:&nbsp;#{(microcredit.remaining_percent*100).round(2)}%</strong>" ] + microcredit.limits.map do |amount, limit|
          "#{number_to_euro amount*100, 0}:&nbsp;#{(microcredit.current_percent(amount)*100).round(2)}%"
        end).join("<br/>").html_safe
      end
      row :progress do
        ["<strong>Objetivo: #{number_to_euro microcredit.total_goal*100, 0}",
          "#{microcredit.campaign_created_count}:&nbsp;#{number_to_euro(microcredit.campaign_created_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_created_amount/microcredit.total_goal, precision:2)})</strong>",
          "#{microcredit.campaign_confirmed_count}&check;:&nbsp;#{number_to_euro(microcredit.campaign_confirmed_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_confirmed_amount/microcredit.campaign_created_amount, precision:2)})",
          "#{microcredit.campaign_unconfirmed_count}&cross;:&nbsp;#{number_to_euro(microcredit.campaign_unconfirmed_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_unconfirmed_amount/microcredit.campaign_created_amount, precision:2)})",
          "#{microcredit.campaign_counted_count}&oplus;:&nbsp;#{number_to_euro(microcredit.campaign_counted_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_counted_amount/microcredit.campaign_created_amount, precision:2)})",
          "#{microcredit.campaign_not_counted_count}&ominus;:&nbsp;#{number_to_euro(microcredit.campaign_not_counted_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_not_counted_amount/microcredit.campaign_created_amount, precision:2)})",
          "#{microcredit.campaign_discarded_count}&#9785;:&nbsp;#{number_to_euro(microcredit.campaign_discarded_amount*100, 0)}&nbsp;(#{number_to_percentage(100.0*microcredit.campaign_discarded_amount/microcredit.campaign_created_amount, precision:2)})"
          ].join("<br/>").html_safe
      end
      row :mailing do
        status_tag("es Mailing", :ok)
      end
      row :reset_at
      row :created_at
      row :updated_at
    end

    panel "Lugares donde se aporta" do
      paginated_collection(microcredit.microcredit_options.page(params[:page]).per(15), download_links: false) do
        table_for collection.order(:name) do
          column :id
          column :parent_id
          column :name
          column :actions do |op|
            span link_to "Modificar", edit_admin_microcredit_microcredit_option_path(op.microcredit, op)
            span link_to "Borrar", admin_microcredit_microcredit_option_path(op.microcredit, op), method: :delete, data: { confirm: "¿Estas segura de borrar esta opción?" }
          end
        end
      end if microcredit.microcredit_options.any?
      span link_to "Añadir opción", new_admin_microcredit_microcredit_option_path(microcredit)
    end

    panel "Evolución" do
      columns do
        column do 
          panel "Evolución €" do 
            render "admin/microcredits_amounts", width: "80%", height: "100"
          end
        end
        column do 
          panel "Evolución #" do 
            render "admin/microcredits_count", width: "80%", height: "100"
          end
        end
      end
    end
    active_admin_comments
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
      li "&#9785; = descartado, no se va a cobrar".html_safe
    end
  end

  sidebar "Estadísticas últimas campañas", only: :index, priority: 0 do
    ul do
      li "Objetivo: #{number_to_euro Microcredit.total_current_amount*100,2}"
      li "Suscrito: #{number_to_euro MicrocreditLoan.amount_current*100,2}<br/>Microcréditos: #{MicrocreditLoan.count_current}<br/>Donantes: #{MicrocreditLoan.unique_current}".html_safe
      li "Visibles: #{number_to_euro MicrocreditLoan.amount_counted_current*100,2}<br/>Microcréditos: #{MicrocreditLoan.count_counted_current}<br/>Donantes: #{MicrocreditLoan.unique_counted_current}".html_safe
      li "Confirmados: #{number_to_euro MicrocreditLoan.amount_confirmed_current*100,2}<br/>Microcréditos: #{MicrocreditLoan.count_confirmed_current}<br/>Donantes: #{MicrocreditLoan.unique_confirmed_current}".html_safe
      li "Descartados: #{number_to_euro MicrocreditLoan.amount_discarded_current*100,2}<br/>Visibles: #{number_to_euro MicrocreditLoan.amount_discarded_counted_current*100,2}<br/>Microcréditos: #{MicrocreditLoan.count_discarded_current}".html_safe
    end
  end

  sidebar "Procesar movimientos del banco", 'data-panel' => :collapsed, :only => :show, priority: 1 do  
    render("admin/process_bank_history")
  end 

  action_item(:change_phase, only: :show) do
    if resource.phase_remaining.sum(&:last)<=0
      link_to('Cambiar de fase', change_phase_admin_microcredit_path(resource), method: :post, data: { confirm: "¿Estas segura de que deseas cambiar de fase en esta campaña?" })
    end
  end

  member_action :change_phase, :method => :post do
    Microcredit.find(params[:id]).change_phase!
    flash[:notice] = "La campaña ha cambiado de fase."
    redirect_to action: :show
  end

  controller do
    def update
      if can? :admin, Microcredit
        super
      else
        current_phase_total = resource.phase_limit_amount
        resource.limits = params[:microcredit].map {|k,v| "#{k[13..-1]} #{v.to_i} " if k.start_with?("single_limit_") } .join ""
        if resource.phase_limit_amount != current_phase_total
          resource.errors.add(:limits, "La suma total de la fase debe permanecer constante en #{current_phase_total}€.")
          show!
        else
          super
        end
      end
    end
  end

  permit_params do
    if can? :admin, Microcredit
      [:title, :starts_at, :ends_at, :limits, :subgoals, :account_number, :total_goal, :bank_counted_amount, :contact_phone, :agreement_link, :budget_link, :renewal_terms, :mailing, :priority]
    else
      [:contact_phone]
    end
  end

  member_action :process_bank_history, :method => :post do
    norma43 = Norma43.read(params["process_bank_history"]["file"].tempfile)

    loans = { sure: [], doubts: [], empty: [], confirmed: [] }
    norma43[:movements].each do |movement|
      temp = []
      sure = false
      muser = I18n.transliterate(movement[:concept][0..37].strip.downcase)
      mconcept = movement[:concept][38..-1]
      id, mname = mconcept.split(/[ -]/, 2) if mconcept

      if mconcept && mname && mname.downcase==resource.title.downcase && id.to_i>0
        sure = true
        temp = resource.loans.where(id: id.to_i)
      end

      if sure and temp.length==1 && temp.first.amount == movement[:amount] && (I18n.transliterate("#{temp.first.last_name} #{temp.first.first_name}".downcase[0..37].strip)==muser || I18n.transliterate("#{temp.first.first_name} #{temp.first.last_name}".downcase[0..37].strip)==muser)
        if temp.first.confirmed_at.nil?
          loans[:sure] << { loans: temp, movement: movement }
        else
          loans[:confirmed] << { loans: temp, movement: movement }
        end
        next
      end

      if mconcept
        ids = mconcept.scan(/(\d{1,7})/).flatten
        temp = resource.loans.where(id: ids.map(&:to_i))
        if temp.length>0
          loans[:doubts] << { loans: temp, movement: movement }
          next
        end
      end

      loans[:empty] << { movement: movement }
    end

    render "admin/process_bank_history_results", locals: { loans: loans }
  end  

end

ActiveAdmin.register MicrocreditOption do
  menu false
  belongs_to :microcredit
  navigation_menu :default

  permit_params :microcredit_id, :name, :parent_id, :intern_code

  form partial: "microcredit_option", locals: { spain: Carmen::Country.coded("ES") }

  controller do
    def create
      super do |format|
        redirect_to admin_microcredit_path(resource.microcredit) and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to admin_microcredit_path(resource.microcredit) and return if resource.valid?
      end
    end
  end
end