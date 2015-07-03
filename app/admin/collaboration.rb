def show_order o, html_output = true
  otext  = if o.has_errors?
              "x"
            elsif o.has_warnings?
              "!"
            elsif o.is_paid?
              "o"
            elsif o.was_returned?
              "d"
            elsif o.is_chargable? or not o.persisted?
              "_"
            else
              "~"
            end
  otext = link_to(otext, admin_order_path(o)).html_safe if o.persisted? and html_output
  otext
end

def show_collaboration_orders(collaboration, html_output = true)
  today = Date.today.unique_month
  output = (collaboration.get_orders(Date.today-6.months, Date.today+6.months).map do |orders|
    odate = orders[0].payable_at
    month = odate.month.to_s
    month = (html_output ? content_tag(:strong, month).html_safe : "|"+month+"|") if odate.unique_month==today
    month_orders = orders.sort_by {|o| o.created_at or Date.civil(2100,1,1) }.map {|o| show_order o, html_output } .join("")
    if html_output
      month + month_orders.html_safe
    else
      month + month_orders
    end
  end) .join(" ")

  html_output ? output.html_safe : output
end

ActiveAdmin.register Collaboration do
  scope_to Collaboration, association_method: :full_view
  config.sort_order = 'updated_at_desc'

  menu :parent => "Colaboraciones"

  permit_params  :user_id, :status, :amount, :frequency, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, 
                :redsys_identifier, :redsys_expiration, :for_autonomy_cc, :for_town_cc

  actions :all, :except => [:new]

  scope :created, default: true
  scope :credit_cards
  scope :bank_nationals
  scope :bank_internationals
  scope :incomplete
  scope :unconfirmed
  scope :active
  scope :warnings
  scope :errors
  scope :legacy
  scope :non_user
  scope :deleted
  scope :autonomy_cc
  scope :town_cc

  index do
    selectable_column
    id_column
    column :user do |collaboration|
      if collaboration.user
        link_to(collaboration.user.full_name, admin_user_path(collaboration.user))
      else
        collaboration.get_user.full_name
      end
    end
    column :amount, sortable: :amount do |collaboration|
      number_to_euro collaboration.amount
    end
    column :orders do |collaboration|
      show_collaboration_orders collaboration
    end
    column :created_at, sortable: :created_at do |collaboration|
      collaboration.created_at.strftime "%d-%m-%y %H-%M"
    end
    column :method, sortable: 'payment_type' do |collaboration|
      collaboration.payment_type==1 ? "Tarjeta" : "Recibo"
    end
    column :territorial do |collaboration|
      status_tag("Cca") if collaboration.for_autonomy_cc
      status_tag("Ccm") if collaboration.for_autonomy_cc and collaboration.for_town_cc
    end
    column :info do |collaboration|
      status_tag("BIC", :error) if collaboration.is_bank? and collaboration.calculate_bic.nil?
      status_tag("Activo", :ok) if collaboration.is_active?
      status_tag("Alertas", :warn) if collaboration.has_warnings?
      status_tag("Errores", :error) if collaboration.has_errors?
      collaboration.deleted? ? status_tag("Borrado", :error) : ""
      if collaboration.redsys_expiration
        if collaboration.redsys_expiration<Date.today
          status_tag("Caducada", :error)
        elsif collaboration.redsys_expiration<Date.today+1.month
          status_tag("Caducará", :warn) 
        end
      end
    end
    actions
  end

  sidebar "Acciones", 'data-panel' => :collapsed, only: :index, priority: 0 do
    status = Collaboration.has_bank_file? Date.today

    h4 "Pagos con tarjeta" 
    ul do
      li link_to 'Cobrar tarjetas', params.merge(:action => :charge), data: { confirm: "Se enviarán los datos de todas las órdenes para que estas sean cobradas. ¿Deseas continuar?" }
    end

    h4 "Recibos"
    ul do
      li link_to 'Crear órdenes de este mes', params.merge(:action => :generate_orders), data: { confirm: "Este carga el sistema, por lo que debe ser lanzado lo menos posible, idealmente una vez al mes. ¿Deseas continuar?" }
      li link_to("Generar fichero para el banco", params.merge(:action => :generate_csv))
      if status[1]
        active = status[0] ? " (en progreso)" : ""
        li link_to("Descargar fichero para el banco#{active}", params.merge(:action => :download_csv))
      end
      li do
        this_month = Order.banks.by_date(Date.today, Date.today).to_be_charged.count
        prev_month = Order.banks.by_date(Date.today-1.month, Date.today-1.month).to_be_charged.count
        """Marcar como enviadas:
        #{link_to Date.today.strftime("%b (#{this_month})").downcase, params.merge(action: :mark_as_charged, date: Date.today), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" } }
        #{link_to (Date.today-1.month).strftime("%b (#{prev_month})").downcase, params.merge(action: :mark_as_charged, date: Date.today-1.month), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" } }
        """.html_safe
      end
      li do
        this_month = Order.banks.by_date(Date.today, Date.today).charging.count
        prev_month = Order.banks.by_date(Date.today-1.month, Date.today-1.month).charging.count
        """Marcar como pagadas:
        #{link_to Date.today.strftime("%b (#{this_month})").downcase, params.merge(action: :mark_as_paid, date: Date.today), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" } }
        #{link_to (Date.today-1.month).strftime("%b (#{prev_month})").downcase, params.merge(action: :mark_as_paid, date: Date.today-1.month), data: { confirm: "Esta acción no se puede deshacer. ¿Deseas continuar?" } }
        """.html_safe
      end
    end

    h4 "Asignación territorial"
    ul do
      li do
        """Autonómica:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_autonomy, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_autonomy, date: Date.today-1.month) }
        """.html_safe
      end
      li do
        """Municipal:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_town, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_town, date: Date.today-1.month) }
        """.html_safe
      end
    end
  end
  
  sidebar "Procesar respuestas del banco", 'data-panel' => :collapsed, :only => :index, priority: 1 do  
    render("admin/process_bank_response")
  end 

  sidebar "Ayuda", 'data-panel' => :collapsed, only: :index, priority: 2 do
    h4 "Nomenclatura de las órdenes"
    ul do
      li "_ = pendiente"
      li "~ = enviada"
      li "o = cobrada"
      li "! = alerta"
      li "x = error"
      li "d = devuelta"
    end
  end

  filter :user_document_vatid_or_non_user_document_vatid, as: :string
  filter :user_email_or_non_user_email, as: :string
  filter :status, :as => :select, :collection => Collaboration::STATUS.to_a
  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES.to_a
  filter :payment_type, :as => :select, :collection => Order::PAYMENT_TYPES.to_a
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS.to_a
  filter :created_at
  filter :for_autonomy_cc
  filter :for_town_cc

  show do |collaboration|
    attributes_table do
      row :user do
        collaboration.get_user
      end
      row :payment_type_name
      row :amount do
        number_to_euro collaboration.amount
      end
      row :frequency_name
      row :status_name
      row :created_at
      row :updated_at
      row :deleted_at
      
      if collaboration.is_bank?
        if collaboration.has_iban_account?
          row :iban_account 
          row :iban_bic do
            status_tag(t("active_admin.empty"), :error) if collaboration.calculate_bic.nil?
            collaboration.calculate_bic
          end
        else
          row :ccc_full
        end
      end
      if collaboration.is_credit_card?
        row :redsys_identifier
        row :redsys_expiration do
          collaboration.redsys_expiration.strftime "%m/%y" if collaboration.redsys_expiration
        end
      end
      row :territorial do
        status_tag("Cc autonómico") if collaboration.for_autonomy_cc
        status_tag("Cc municipal") if collaboration.for_autonomy_cc and collaboration.for_town_cc
      end
      row :info do
        status_tag("Cca", :ok) if collaboration.for_autonomy_cc
        status_tag("Ccm", :ok) if collaboration.for_autonomy_cc and collaboration.for_town_cc
        status_tag("Activo", :ok) if collaboration.is_active?
        status_tag("Alertas", :warn) if collaboration.has_warnings?
        status_tag("Errores", :error) if collaboration.has_errors?
        collaboration.deleted? ? status_tag("Borrado", :error) : ""
        if collaboration.redsys_expiration
          if collaboration.redsys_expiration<Date.today
            status_tag("Caducada", :error)
          elsif collaboration.redsys_expiration<Date.today+1.month
            status_tag("Caducará", :warn) 
          end
        end
      end
    end
    if collaboration.get_non_user
      panel "Colaboración antigua" do
        attributes_table_for collaboration.get_non_user do
          row :legacy_id 
          row :full_name
          row :document_vatid
          row :email
          row :address
          row :town_name
          row :postal_code
          row :country
          row :province
          row :phone 
        end
      end
    end
    panel "Órdenes de pago" do
      table_for collaboration.order.sort { |a,b| b.payable_at <=> a.payable_at } do
        column :id do |order|
          link_to order.id, admin_order_path(order.id)
        end
        column :status do |order|
          order.status_name
        end
        column :amount do |order|
          number_to_euro order.amount
        end
        column :payable_at  
        column :payed_at
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Colaboración" do
      f.input :user_id
      f.input :status, as: :select, collection: Collaboration::STATUS.to_a
      f.input :amount, as: :radio, collection: Collaboration::AMOUNTS.to_a #, input_html: {disabled: true}
      f.input :frequency, as: :radio, collection: Collaboration::FREQUENCIES.to_a #, input_html: {disabled: true}
      f.input :payment_type, as: :radio, collection: Order::PAYMENT_TYPES.to_a #, input_html: {disabled: true}
      f.input :ccc_entity
      f.input :ccc_office
      f.input :ccc_dc
      f.input :ccc_account
      f.input :iban_account
      f.input :iban_bic
      f.input :redsys_identifier
      f.input :redsys_expiration
      f.input :for_autonomy_cc
      f.input :for_town_cc
    end
    f.actions
  end
  
  collection_action :charge, :method => :get do
    Collaboration.credit_cards.pluck(:id).each do |cid|
      Resque.enqueue(PodemosCollaborationWorker, cid)
    end
    redirect_to :admin_collaborations
  end

  collection_action :generate_orders, :method => :get do
    Collaboration.banks.pluck(:id).each do |cid|
      Resque.enqueue(PodemosCollaborationWorker, cid)
    end
    redirect_to :admin_collaborations
  end

  collection_action :generate_csv, :method => :get do
    Collaboration.bank_file_lock true
    Resque.enqueue(PodemosCollaborationWorker, -1)
    redirect_to :admin_collaborations
  end

  collection_action :download_csv, :method => :get do
    status = Collaboration.has_bank_file? Date.today
    if status[1]
      send_file Collaboration.bank_filename Date.today
    else
      flash[:notice] = "El fichero no existe aún"
      redirect_to :admin_collaborations
    end
  end

  collection_action :mark_as_charged, :method => :get do
    date = Date.parse params[:date]
    Order.mark_bank_orders_as_charged! date
    redirect_to :admin_collaborations
  end

  collection_action :mark_as_paid, :method => :get do
    date = Date.parse params[:date]
    Order.mark_bank_orders_as_paid! date
    redirect_to :admin_collaborations
  end

  collection_action :process_bank_response, :method => :post do
    messages = []
    xml = Nokogiri::XML(params["process_bank_response"]["file"])
    xml.remove_namespaces!
    items = xml.xpath('/Document/CstmrPmtStsRpt/OrgnlPmtInfAndSts/TxInfAndSts')
    items.each do |item|
      begin
        code = item.at_xpath("StsRsnInf/Rsn/Cd").text
        col_id = item.at_xpath("OrgnlTxRef/MndtRltdInf/MndtId").text.to_i
        date = Date.parse item.at_xpath("OrgnlTxRef/MndtRltdInf/DtOfSgntr").text
        iban = item.at_xpath("OrgnlTxRef/DbtrAcct/Id/IBAN").text
        bic = item.at_xpath("OrgnlTxRef/DbtrAgt/FinInstnId/BIC").text
        fullname = item.at_xpath("OrgnlTxRef/Dbtr/Nm").text
        orders = nil
        if date > Date.civil(2015,1,31)
          col = Collaboration.with_deleted.joins(:order).find_by_id(col_id)
        else
          cols = Collaboration.with_deleted.joins(:user).eager_load(:order).where(iban_account: iban).select do |c|
            I18n.transliterate(c.get_non_user.full_name).upcase == fullname
          end
          col = cols.first if cols.length == 1
        end
        if col
          orders = col.get_orders(date, date)[0]
          if orders[-1].payment_identifier == "#{iban}/#{bic}"
            if orders[-1].is_paid?
              if orders[-1].mark_as_returned! code
                result = :ok
              else
                result = :no_mark
              end
            else
              result = :no_order
            end
          else
            result = :wrong_account
          end
        else
          result = :no_collaboration
        end
        messages << { result: result, collaboration: (col or col_id), date: date, ret_code: code, orders: orders, account: "#{iban}/#{bic}", fullname: fullname }
      rescue
        messages << { result: :error, info: item, message: $!.message }
      end
    end
    render "admin/process_bank_response_results", locals: {messages: messages}
  end  

  member_action :charge_order do
    resource.charge!
    redirect_to admin_collaboration_path(id: resource.id)
  end

  action_item(:charge_collaboration, only: :show) do
    if resource.is_credit_card? 
      link_to 'Cobrar', charge_order_admin_collaboration_path(id: resource.id), data: { confirm: "Se enviarán los datos de la orden para que esta sea cobrada. ¿Deseas continuar?" }
    else
      link_to 'Generar orden', charge_order_admin_collaboration_path(id: resource.id)
    end
  end

  action_item(:restore_collaboration, only: :show) do
    link_to('Recuperar colaboración borrada', recover_admin_collaboration_path(collaboration), method: :post, data: { confirm: "¿Estas segura de querer recuperar esta colaboración?" }) if collaboration.deleted?
  end

  member_action :recover, :method => :post do
    collaboration = Collaboration.with_deleted.find(params[:id])
    collaboration.restore
    flash[:notice] = "Ya se ha recuperado la colaboración."
    redirect_to action: :show
  end

  csv do
    column :id
    column :full_name do |collaboration|
      collaboration.get_user.full_name
    end
    column :dni_nie do |collaboration|
      collaboration.get_user.document_vatid.upcase if collaboration.get_user.document_vatid
    end
    column :email do |collaboration|
      collaboration.get_user.email
    end
    column :address do |collaboration|
      collaboration.get_user.address
    end
    column :town do |collaboration|
      collaboration.get_user.town_name
    end
    column :postal_code do |collaboration|
      collaboration.get_user.postal_code
    end
    column :country do |collaboration|
      collaboration.get_user.country
    end
    column :frequency_name
    column :amount do |collaboration|
      collaboration.amount
    end
    column :total_amount do |collaboration|
      collaboration.amount * collaboration.frequency
    end
    column :payment_type_name
    column :ccc_full
    column :iban_account
    column :iban_bic do |collaboration|
      collaboration.calculate_bic
    end
    column :created_at
    column :info do |collaboration|
      if collaboration.has_errors?
        "Errores"
      elsif collaboration.has_warnings?
        "Alertas"
      else
        "OK"
      end
    end
    column :user do |collaboration|
      collaboration.user_id if collaboration.user_id
    end
    column :amount_current do |collaboration|
      collaboration.skip_queries_validations = true
      if collaboration.is_payable? and collaboration.must_have_order? Date.today
        (collaboration.amount/100 * collaboration.frequency) 
      else
        0
      end
    end
  end

  collection_action :download_for_autonomy, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..3).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]

    autonomies = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    autonomies_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.where.not(autonomy_code:nil).group(:autonomy_code, Order.unique_month("payable_at")).sum(:amount).each do |k,v|
      autonomies_data[k[0]][k[1].to_i] = v
    end

    csv = CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      csv << ["Comunidad Autónoma"] + months.values
      autonomies_data.each do |k,v|
        csv << [autonomies[k] ] + months.keys.map{|k| v[k]/100}
      end
    end

    send_data csv.encode('utf-8'),
      type: 'text/tsv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.for_autonomy_cc.#{Date.today.to_s}.csv"
  end

  collection_action :download_for_town, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..3).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]

    provinces = Carmen::Country.coded("ES").subregions
    towns_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.where.not(autonomy_code:nil).where.not(town_code:nil).group(:town_code, Order.unique_month("payable_at")).sum(:amount).each do |k,v|
      towns_data[k[0]][k[1].to_i] = v
    end

    csv = CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      csv << ["Comunidad Autónoma", "Provincia", "Municipio"] + months.values
      provinces.each_with_index do |province,i|
        prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
        province.subregions.each do |town|
          csv << [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name ] + months.keys.map{|k| towns_data[town.code][k]/100}
        end
      end
    end

    send_data csv.encode('utf-8'),
      type: 'text/tsv; charset=utf-8; header=present',
      disposition: "attachment; filename=podemos.for_town_cc.#{Date.today.to_s}.csv"
  end
end
