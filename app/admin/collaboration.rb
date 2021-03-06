require 'collaborations_on_paper'
def show_order(o, html_output = true)
  text = if o.has_errors?
           "x"
         elsif o.has_warnings?
           "!"
         elsif o.is_paid?
           "o"
         elsif o.was_returned?
           "d"
         elsif o.is_chargeable? or not o.persisted?
           "_"
         else
           "~"
         end
  text = link_to(text, admin_order_path(o)).html_safe if o.persisted? and html_output
  text
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

def send_csv_file(header1, months, output_data, filename)
  header2 = Array.new(header1.size, "")

  header1 += months.values.flat_map { |e| [e, ""] }
  header2 += Array.new(months.size, ["Num. Colaboraciones", "Suma Importes"]).flatten

  file_csv = CSV.generate(encoding: 'utf-8', col_sep: "\t") do |writer|
    writer << header1
    writer << header2

    output_data.each do |row|
      writer << row
    end
  end

  send_data file_csv.encode('utf-8'),
            type: 'text/tsv; charset=utf-8; header=present',
            disposition: "attachment; filename=#{filename}"
end

ActiveAdmin.register Collaboration do
  scope_to Collaboration, association_method: :full_view
  config.sort_order = 'updated_at_desc'

  menu :parent => "Colaboraciones"

  permit_params  :user_id, :status, :amount, :frequency, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, 
    :redsys_identifier, :redsys_expiration, :for_autonomy_cc, :for_town_cc, :for_island_cc

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
  scope :suspects
  scope :legacy
  scope :non_user
  scope :deleted
  scope :autonomy_cc
  scope :town_cc
  scope :island_cc

  index download_links: -> { current_user.is_admin? && current_user.finances_admin? } do
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
      status_tag("Ccm") if collaboration.for_town_cc
      status_tag("Cci") if collaboration.for_island_cc
    end
    column :info do |collaboration|
      status_tag("BIC", :error) if collaboration.is_bank? && collaboration.calculate_bic.nil?
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

    # h4 "Asignación territorial (base territorio inscrito)"
    # ul do
    #   li do
    #     """Autonómica:
    #     #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_autonomy, date: Date.today) }
    #     #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_autonomy, date: Date.today-1.month) }
    #     """.html_safe
    #   end
    #   li do
    #     """Municipal:
    #     #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_town, date: Date.today) }
    #     #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_town, date: Date.today-1.month) }
    #     """.html_safe
    #   end
    #   li do
    #     """Insular:
    #     #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_island, date: Date.today) }
    #     #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_island, date: Date.today-1.month) }
    #     """.html_safe
    #   end
    # end

    h4 "Asignación territorial (Base círculo Inscrito y territorio si no círculo)"
    ul do
      li do
        """Autonómica:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_vote_circle_autonomy, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_vote_circle_autonomy, date: Date.today-1.month) }
        """.html_safe
      end
      li do
        """Municipal:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_vote_circle_town, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_vote_circle_town, date: Date.today-1.month) }
        """.html_safe
      end
      li do
        """Insular:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_vote_circle_island, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_vote_circle_island, date: Date.today-1.month) }
        """.html_safe
      end
    end

    h4 "Listados Especiales por Círculo y Código Postal"
    ul do
      # li do
      #   """por Código Postal:
	    #   #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_cp, date: Date.today) }
      #   #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_cp, date: Date.today-1.month) }
      #   """.html_safe
      # end
      #
      # li do
      #   """por Círculo:
	    #   #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_circle, date: Date.today) }
      #   #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_circle, date: Date.today-1.month) }
      #   """.html_safe
      # end
      #
      # li do
      #   """por Círculo y Código Postal:
	    #   #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp, date: Date.today) }
      #   #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp, date: Date.today-1.month) }
      #   """.html_safe
      # end

      li do
        """Asignación autonómica:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_autonomy, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_autonomy, date: Date.today-1.month) }
        """.html_safe
      end

      li do
        """Asignación municipal:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_town, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_town, date: Date.today-1.month) }
        """.html_safe
      end

      li do
        """Asignación estatal:
        #{link_to Date.today.strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_country, date: Date.today) }
        #{link_to (Date.today-1.month).strftime("%b").downcase, params.merge(action: :download_for_circle_and_cp_country, date: Date.today-1.month) }
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

  sidebar "Añadir Colaboraciones en formato papel", 'data-panel' => :collapsed, :only => :index, priority: 1 do
    render('process_collaborations_on_paper')
  end

  filter :user_first_name, as: :string
  filter :user_last_name, as: :string
  filter :iban_account, as: :string
  filter :user_document_vatid_or_non_user_document_vatid, as: :string
  filter :user_email_or_non_user_email, as: :string
  filter :non_user_data, as: :string
  filter :status, :as => :select, :collection => Collaboration::STATUS.to_a
  filter :frequency, :as => :select, :collection => Collaboration::FREQUENCIES.to_a
  filter :payment_type, :as => :select, :collection => Order::PAYMENT_TYPES.to_a
  filter :amount, :as => :select, :collection => Collaboration::AMOUNTS.to_a
  filter :created_at
  filter :for_autonomy_cc
  filter :for_town_cc
  filter :for_island_cc

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
      row :es_militante do |collaboration|
        collaboration.get_user.still_militant? if collaboration.user_id.present? && collaboration.get_user
      end
      row :circulo do |collaboration|
        collaboration.get_user.vote_circle.original_name if collaboration.get_user && collaboration.get_user.vote_circle_id.present?
      end
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
      row :info do
        status_tag("Cc autonómico", :ok) if collaboration.for_autonomy_cc
        status_tag("Cc municipal", :ok) if collaboration.for_town_cc
        status_tag("Cc insular", :ok) if collaboration.for_island_cc
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
      f.input :for_island_cc
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
        order_id = item.at_xpath("OrgnlTxRef/MndtRltdInf/MndtId").text[4..-1].to_i
        #date = item.at_xpath("OrgnlTxRef/MndtRltdInf/DtOfSgntr").text.to_date
        iban = item.at_xpath("OrgnlTxRef/DbtrAcct/Id/IBAN").text.upcase
        bic = item.at_xpath("OrgnlTxRef/DbtrAgt/FinInstnId/BIC").text.upcase
        fullname = item.at_xpath("OrgnlTxRef/Dbtr/Nm").text

        order= Order.find(order_id)
        if order
          if order.payment_identifier.gsub(' ','').upcase == "#{iban}/#{bic}"
            if order.is_paid?
              if order.processed! code
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

          messages << { result: result, order: (order), ret_code: code, account: "#{iban}/#{bic}", fullname:                   fullname }
      rescue
        messages << { result: :error, info: item, message: $!.message }
      end
    end
    render "admin/process_bank_response_results", locals: {messages: messages}
  end  

  collection_action :process_collaborations_on_paper, :method => :post do
    file_input = params["process_collaborations_on_paper"]["file"].tempfile
    @collaborations_on_paper = CollaborationsOnPaper.new(file_input)
    if @collaborations_on_paper.all_ok?
    if @collaborations_on_paper.has_errors_on_save?
      flash_type = :error
      message = "Ha habido algún error al guardar las colaboraciones en papel. Por favor, intentelo de nuevo y avise a Informática"
    else
      flash_type = :notice
      message = "Todas las colaboraciones en papel han sido dadas de alta satisfactoriamente"
    end
    else
      flash_type = :error
      message = "Ha habido algún error en el fichero de las colaboraciones en papel. Por favor, corrijalo e intentelo de nuevo"
    end
    flash[flash_type] = message
    render("admin/collaborations/collaborations_on_paper")

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
    column :postal_code do |collaboration|
      collaboration.get_user.postal_code
    end
    column :town do |collaboration|
      collaboration.get_user.town_name
    end
    column :province do |collaboration|
      collaboration.get_user.province_name
    end
    column :island do |collaboration|
      collaboration.get_user.province_name
    end
    column :autonomy do |collaboration|
      collaboration.get_user.autonomy_name
    end
    column :province do |collaboration|
      collaboration.get_user.province_name
    end
    column :island do |collaboration|
      collaboration.get_user.island_name
    end
    column :autonomy do |collaboration|
      collaboration.get_user.autonomy_name
    end
    column :country do |collaboration|
      collaboration.get_user.country
    end
    column :collabortion_type do |collaboration|
      collaboration.for_island_cc ? "I" : collaboration.for_town_cc ? "M" : collaboration.for_autonomy_cc ? "A" : "E"
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
    column :for_country_cc do |collaboration|
      !(collaboration.for_autonomy_cc || collaboration.for_island_cc || collaboration.for_town_cc)
    end
    column :for_autonomy_cc
    column :for_island_cc
    column :for_town_cc
  end

  collection_action :download_for_town, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..5).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    provinces = Carmen::Country.coded("ES").subregions
    towns_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.group(:town_code, Order.unique_month('payable_at')).order(:town_code, Order.unique_month('payable_at')).pluck('town_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      towns_data[c][m.to_i]=[t,v]
    end

    output_data = []
    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name ]
        months.keys.each do |month|
          row.push(towns_data[town.code][month][0])
          row.push(towns_data[town.code][month][1]/100)
        end
        output_data << row
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Municipio"]
    send_csv_file(headers,months,output_data,"podemos.for_town_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_autonomy, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..5).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]

    autonomies = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    autonomies["~"] = "Sin asignación"
    autonomies_data = Hash.new {|h,k| h[k] = Hash.new 0 }

    Order.paid.where(town_code:nil, island_code:nil).group('autonomy_code',Order.unique_month('payable_at')).order('autonomy_code', Order.unique_month('payable_at')).pluck('autonomy_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      autonomies_data[c||"~"][m.to_i]=[t,v]
    end

    output_data = []
    autonomies.sort.each do |autonomy_code,autonomy|
      row = [autonomy]
      months.keys.each do |month|
        row.push(autonomies_data[autonomy_code][month][0])
        row.push(autonomies_data[autonomy_code][month][1]/100)
      end
      output_data << row
    end

    headers = ["Comunidad Autónoma"]
    send_csv_file(headers,months,output_data,"podemos.for_autonomy_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_island, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..5).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]

    islands = Hash.new {|h,k| h[k] = [] }
    Podemos::GeoExtra::ISLANDS.each do |town, info|
      islands["p_#{town[2..3]}"] << info
    end
    islands.each {|_, info| info.uniq! }

    provinces = Carmen::Country.coded("ES").subregions

    island_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.where(town_code:nil).group('island_code',Order.unique_month('payable_at')).order('island_code', Order.unique_month('payable_at')).pluck('island_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      island_data[c][m.to_i]=[t,v]
    end

    output_data = []
    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      islands[prov_code].each do |island_code, island_name|
        row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, island_name ]
        months.keys.each do |month|
          puts("#{island_code} #{month}")
          row.push(island_data[island_code][month][0])
          row.push(island_data[island_code][month][1]/100)
        end
        output_data << row
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Isla"]
    send_csv_file(headers,months,output_data,"podemos.for_island_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_vote_circle_town, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..6).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    provinces = Carmen::Country.coded("ES").subregions
    towns_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.where("target_territory like 'Municipal%'").group(:vote_circle_town_code, Order.unique_month('payable_at')).order(:vote_circle_town_code, Order.unique_month('payable_at')).pluck('vote_circle_town_code', Order.unique_month('payable_at'), 'count(id) as count_id', 'sum(amount) as sum_amount').each do|c,m,t,v|
      towns_data[c][m.to_i]=[t,v]
    end
    Order.paid.where("target_territory like 'Municipal%'").where(vote_circle_town_code:nil).where.not(town_code:nil).group(:town_code, Order.unique_month('payable_at')).order(:town_code, Order.unique_month('payable_at')).pluck('town_code', Order.unique_month('payable_at'), 'count(id) as count_id', 'sum(amount) as sum_amount').each do|c,m,t,v|
      circle_data = towns_data[c][m.to_i]
      result = circle_data[0] + t,circle_data[1] + v
      towns_data[c][m.to_i] = result
    end

    output_data = []
    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name ]
        months.keys.each do |month|
          row.push(towns_data[town.code][month][0])
          row.push(towns_data[town.code][month][1]/100)
        end
        output_data << row
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Municipio"]
    send_csv_file(headers,months,output_data,"circulos.for_town_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_vote_circle_autonomy, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..6).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    autonomies = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    autonomies["~"] = "Sin asignación"
    autonomies_data = Hash.new {|h,k| h[k] = Hash.new 0 }

    Order.paid.where("target_territory like 'Autonómico%'").where(town_code:nil, vote_circle_town_code:nil, island_code:nil, vote_circle_island_code:nil).group('vote_circle_autonomy_code',Order.unique_month('payable_at')).order('vote_circle_autonomy_code', Order.unique_month('payable_at')).pluck('vote_circle_autonomy_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      autonomies_data[c][m.to_i]=[t,v]
    end
    Order.paid.where(town_code:nil, vote_circle_town_code:nil, island_code:nil, vote_circle_island_code:nil, vote_circle_autonomy_code:nil).group(:autonomy_code,Order.unique_month('payable_at')).order(:autonomy_code, Order.unique_month('payable_at')).pluck('autonomy_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      circle_data = autonomies_data[c||"~"][m.to_i]
      result = circle_data[0] + t,circle_data[1] + v
      autonomies_data[c||"~"][m.to_i] = result
    end

    output_data = []
    autonomies.sort.each do |autonomy_code,autonomy|
      row = [autonomy]
      months.keys.each do |month|
        row.push(autonomies_data[autonomy_code][month][0])
        row.push(autonomies_data[autonomy_code][month][1]/100)
      end
      output_data << row
    end

    headers = ["Comunidad Autónoma"]
    send_csv_file(headers,months,output_data,"circulos.for_autonomy_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_vote_circle_island, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..6).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]

    islands = Hash.new {|h,k| h[k] = [] }
    Podemos::GeoExtra::ISLANDS.each do |town, info|
      islands["p_#{town[2..3]}"] << info
    end
    islands.each {|_, info| info.uniq! }

    provinces = Carmen::Country.coded("ES").subregions

    island_data = Hash.new {|h,k| h[k] = Hash.new 0 }
    Order.paid.where(vote_circle_town_code:nil).group('vote_circle_island_code',Order.unique_month('payable_at')).order('vote_circle_island_code', Order.unique_month('payable_at')).pluck('vote_circle_island_code', Order.unique_month('payable_at'), 'count(id) as count_id, sum(amount) as sum_amount').each do|c,m,t,v|
      island_data[c][m.to_i] = [t,v]
    end

    output_data = []
    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      islands[prov_code].each do |island_code, island_name|
        row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, island_name ]
        months.keys.each do |month|
          puts("#{island_code} #{month}")
          row.push(island_data[island_code][month][0])
          row.push(island_data[island_code][month][1]/100)
        end
        output_data << row
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Isla"]
    send_csv_file(headers,months,output_data,"circulos.for_island_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_circle_and_cp_town, :method => :get do
    date =Date.parse params[:date]
    months = Hash[(0..7).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    provinces = Carmen::Country.coded("ES").subregions
    output_data = []

    # ---------------------- Generate Circle Data ---------------------------------------------------------------------------------

    circle_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.where("target_territory like ?",'Municipal%').where.not(vote_circle_id: nil, vote_circle_town_code: nil).where("amount > 0").group(:vote_circle_town_code,:vote_circle_id,:target_territory, Order.unique_month('payable_at')).order(:vote_circle_town_code, :vote_circle_id, :target_territory, Order.unique_month('payable_at')).pluck(:vote_circle_town_code, :vote_circle_id, :target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id, sum(orders.amount) as sum_amount, vote_circle_id as vc')
    query.each do|c,vc,tt,m,t,v|
      num_month = m.to_i
      if circle_data[c][vc][tt][num_month] == 0
        circle_data[c][vc][tt][num_month] = [t,v]
      else
        circle_data[c][vc][tt][num_month][0] += t
        circle_data[c][vc][tt][num_month][1] += v
      end
    end

    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        circle_data[town.code].keys.each do |vc|
          vote_circle = VoteCircle.find(vc)
          tts = circle_data[town.code][vc].keys
          tts = [""] if tts.count == 0
          tts.each do |tt|
            row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name,vote_circle.original_name,"",tt ]
            sum_row = 0
            months.keys.each do |month|
              amount_month = circle_data[town.code][vc][tt][month][1]/100
              row.push(circle_data[town.code][vc][tt][month][0])
              row.push(amount_month)
              sum_row += amount_month
            end
            output_data << row
          end
        end
      end
    end

    # ----------------------- Generate Postal Code data ---------------------------------------------------------------------------

    towns_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.joins("LEFT JOIN users on orders.user_id = users.id").where("orders.target_territory like ?",'Municipal%').where("orders.vote_circle_town_code is not null and orders.amount > 0").where("orders.vote_circle_id is null").group(:vote_circle_town_code, 'users.postal_code', :target_territory, Order.unique_month('payable_at')).order(:vote_circle_town_code, 'users.postal_code',:target_territory, Order.unique_month('payable_at')).pluck(:vote_circle_town_code, 'users.postal_code',:target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount')
    query.each do|c,cp,tt,m,t,v|
      num_month = m.to_i
      if towns_data[c][cp][tt][num_month] == 0
        towns_data[c][cp][tt][num_month] = [t,v]
      else
        towns_data[c][cp][tt][num_month][0] += t
        towns_data[c][cp][tt][num_month][1] += v
      end
    end

    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        towns_data[town.code].keys.each do |cp|
          tts = towns_data[town.code][cp].keys
          tts = [""] if tts.count == 0
          tts.each do |tt|
            row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name,"",cp,tt ]
            sum_row = 0
            months.keys.each do |month|
              amount_month = towns_data[town.code][cp][tt][month][1]/100
              row.push(towns_data[town.code][cp][tt][month][0])
              row.push(amount_month)
              sum_row += amount_month
            end
            output_data << row if sum_row > 0
          end
        end
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Municipio", "Círculo", "Código Postal","Territorio de Asignación"]
    send_csv_file(headers,months,output_data,"podemos.user_for_cp_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_circle_and_cp_autonomy, :method => :get do
    date = Date.parse params[:date]
    months = Hash[(0..7).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    provinces = Carmen::Country.coded("ES").subregions
    autonomies = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    output_data = []

    # ---------------------- Generate Circle Data ---------------------------------------------------------------------------------

    circle_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.where("target_territory like ?",'Autonómico%').where.not(vote_circle_id: nil, vote_circle_autonomy_code: nil).where("amount > 0").group(:vote_circle_autonomy_code,:vote_circle_id,:target_territory, Order.unique_month('payable_at')).order(:vote_circle_autonomy_code, :vote_circle_id, :target_territory, Order.unique_month('payable_at')).pluck(:vote_circle_autonomy_code, :vote_circle_id, :target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount, vote_circle_id as vc')
    query.each do|c,vc,tt,m,t,v|
      num_month = m.to_i
      if circle_data[c][vc][tt][num_month] == 0
        circle_data[c][vc][tt][num_month] = [t,v]
      else
        circle_data[c][vc][tt][num_month][0] += t
        circle_data[c][vc][tt][num_month][1] += v
      end
    end

    autonomies.sort.each do |autonomy_code,autonomy|

        circle_data[autonomy_code].keys.each do |vc|
          vote_circle = VoteCircle.find(vc)
          tts = circle_data[autonomy_code][vc].keys
          tts = [""] if tts.count == 0
          tts.each do |tt|
            row = [ autonomy,"","",vote_circle.original_name,"",tt ]
            sum_row = 0
            months.keys.each do |month|
              amount_month = circle_data[autonomy_code][vc][tt][month][1]/100
              row.push(circle_data[autonomy_code][vc][tt][month][0])
              row.push(amount_month)
              sum_row += amount_month
            end
            output_data << row
          end
        end
    end

    # ----------------------- Generate Postal Code data ---------------------------------------------------------------------------

    towns_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.joins("LEFT JOIN users on orders.user_id = users.id").where("orders.target_territory like ?",'Autonómico%').where("orders.vote_circle_autonomy_code is not null and orders.amount > 0").where("orders.vote_circle_id is null").group('users.vote_town', 'users.postal_code', :target_territory, Order.unique_month('payable_at')).order('users.vote_town', 'users.postal_code',:target_territory, Order.unique_month('payable_at')).pluck('users.vote_town', 'users.postal_code',:target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount')
    query.each do|c,cp,tt,m,t,v|
      num_month = m.to_i
      if towns_data[c][cp][tt][num_month] == 0
        towns_data[c][cp][tt][num_month] = [t,v]
      else
        towns_data[c][cp][tt][num_month][0] += t
        towns_data[c][cp][tt][num_month][1] += v
      end
    end

    # -------------------------- Add Non User data --------------------------------------------------------------------------------
    c_ids = Order.paid.joins("LEFT JOIN users on orders.user_id = users.id").where("orders.target_territory like ?",'Autonómico%').where("orders.vote_circle_autonomy_code is not null and orders.amount > 0").where("orders.vote_circle_id is null").where("users.id is null").pluck(:parent_id).uniq!
    Collaboration.where(id:c_ids).each do |collaboration|
      query = Order.paid.where(parent_id: collaboration.id).group(:target_territory, Order.unique_month('payable_at')).order(:target_territory, Order.unique_month('payable_at')).pluck(:target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount')
      query.each do|tt,m,t,v|
        non_user = collaboration.get_non_user
        c = non_user.ine_town
        cp = non_user.postal_code
        num_month = m.to_i
        if towns_data[c][cp][tt][num_month] == 0
          towns_data[c][cp][tt][num_month] = [t,v]
        else
          towns_data[c][cp][tt][num_month][0] += t
          towns_data[c][cp][tt][num_month][1] += v
        end
      end
    end

    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        towns_data[town.code].keys.each do |cp|
          tts = towns_data[town.code][cp].keys
          tts = [""] if tts.count == 0
          tts.each do |tt|
            row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name,"",cp,tt ]
            sum_row = 0
            months.keys.each do |month|
              amount_month = towns_data[town.code][cp][tt][month][1]/100
              row.push(towns_data[town.code][cp][tt][month][0])
              row.push(amount_month)
              sum_row += amount_month
            end
            output_data << row if sum_row > 0
          end
        end
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Municipio", "Círculo", "Código Postal","Territorio de Asignación"]
    send_csv_file(headers,months,output_data,"podemos.user_for_cp_cc.#{Date.today.to_s}.csv")
  end

  collection_action :download_for_circle_and_cp_country, :method => :get do
    date =Date.parse params[:date]
    months = Hash[(0..7).map{|i| [(date-i.months).unique_month, (date-i.months).strftime("%b").downcase]}.reverse]
    provinces = Carmen::Country.coded("ES").subregions
    autonomies = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    countries = Hash[ Carmen::Country.all.map do |c| [ c.code,c.name ] end ]
    output_data = []

    # ---------------------- Generate Circle Data ---------------------------------------------------------------------------------

    circle_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.where("target_territory like ?",'Estatal%').where.not(vote_circle_id: nil).where( vote_circle_autonomy_code: nil, vote_circle_island_code: nil, vote_circle_town_code: nil).where("amount > 0").group(:vote_circle_id,:target_territory, Order.unique_month('payable_at')).order(:vote_circle_id, :target_territory, Order.unique_month('payable_at')).pluck(:vote_circle_id, :target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount, vote_circle_id as vc')
    query.each do|vc,tt,m,t,v|
      num_month = m.to_i
      if circle_data[vc][tt][num_month] == 0
        circle_data[vc][tt][num_month] = [t,v]
      else
        circle_data[vc][tt][num_month][0] += t
        circle_data[vc][tt][num_month][1] += v
      end
    end

    VoteCircle.all.sort.each do |vc|
      tts = circle_data[vc.id].keys
      tts = [""] if tts.count == 0
      tts.each do |tt|
        row = [ "","","",vc.original_name,"",tt ]
        sum_row = 0
        months.keys.each do |month|
          amount_month = circle_data[vc.id][tt][month][1]/100
          row.push(circle_data[vc.id][tt][month][0])
          row.push(amount_month)
          sum_row += amount_month
        end
        output_data << row if sum_row > 0
      end
    end

    # ----------------------- Generate Postal Code data ---------------------------------------------------------------------------

    towns_data = Hash.new {|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k]= 0}}}}
    query = Order.paid.joins("LEFT JOIN users on orders.user_id = users.id").where("orders.target_territory like ?",'Estatal%').where( vote_circle_autonomy_code: nil, vote_circle_island_code: nil, vote_circle_town_code: nil).where("orders.amount > 0").where("orders.vote_circle_id is null").group('users.vote_town', 'users.postal_code', :target_territory, Order.unique_month('payable_at')).order('users.vote_town', 'users.postal_code',:target_territory, Order.unique_month('payable_at')).pluck('users.vote_town', 'users.postal_code',:target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount')
    query.each do|c,cp,tt,m,t,v|
      next unless cp
      num_month = m.to_i
      if towns_data[c][cp][tt][num_month] == 0
        towns_data[c][cp][tt][num_month] = [t,v]
      else
        towns_data[c][cp][tt][num_month][0] += t
        towns_data[c][cp][tt][num_month][1] += v
      end
    end

    # -------------------------- Add Non User data --------------------------------------------------------------------------------
    non_user_base = Order.paid.joins("LEFT JOIN users on orders.user_id = users.id").where("orders.target_territory like ?",'Estatal%').where( vote_circle_autonomy_code: nil, vote_circle_island_code: nil, vote_circle_town_code: nil).where("orders.amount > 0 and orders.vote_circle_id is null and users.id is null")
    c_ids = non_user_base.pluck(:parent_id)
    Collaboration.with_deleted.where(id:c_ids).each do |collaboration|
      query = non_user_base.where(parent_id:collaboration.id).group(:target_territory, Order.unique_month('payable_at')).order(:target_territory, Order.unique_month('payable_at')).pluck(:target_territory, Order.unique_month('payable_at'), 'count(orders.id) as count_id', 'sum(orders.amount) as sum_amount')
      query.each do|tt,m,t,v|
        non_user = collaboration.get_non_user
        c = non_user.ine_town
        c = non_user.town_name unless c.present?
        c = "desconocido" unless c.present?
        cp = non_user.postal_code
        cp = "desconocido" unless cp.present?
        deleted_month = collaboration.deleted_at.unique_month.to_i if collaboration.deleted_at
        num_month = m.to_i
        if deleted_month.nil? || deleted_month >= num_month
          if towns_data[c][cp][tt][num_month] == 0
            towns_data[c][cp][tt][num_month] = [t,v]
          else
            towns_data[c][cp][tt][num_month][0] += t
            towns_data[c][cp][tt][num_month][1] += v
          end
        end
      end
    end

    # prepare rows to export
    towns_keys =[]
    provinces.each_with_index do |province,i|
      prov_code = "p_#{(i+1).to_s.rjust(2, "0")}"
      province.subregions.each do |town|
        towns_keys << town.code
        towns_data[town.code].keys.each do |cp|
          tts = towns_data[town.code][cp].keys
          tts = [""] if tts.count == 0
          tts.each do |tt|
            row = [ Podemos::GeoExtra::AUTONOMIES[prov_code][1], province.name, town.name,"",cp,tt ]
            sum_row = 0
            months.keys.each do |month|
              amount_month = towns_data[town.code][cp][tt][month][1]/100
              row.push(towns_data[town.code][cp][tt][month][0])
              row.push(amount_month)
              sum_row += amount_month
            end
            output_data << row if sum_row > 0
          end
        end
      end
    end

    # add non standard town_codes found
    #towns = towns_data.keys
    towns_exterior = towns_data.keys - towns_keys #towns.reject {|t| t =~ /m_\d{2}_\d{3}_\d/}
    #towns_exterior -=[nil]
    towns_exterior.each do |town_code|
      towns_data[town_code].keys.each do |cp|
        tts = towns_data[town_code][cp].keys
        tts = [""] if tts.count == 0
        tts.each do |tt|
          cp_txt = cp
          cp_txt = "desconocido" unless cp.present?
          row = [ town_code, town_code, town_code,"",cp_txt,tt ]
          sum_row = 0
          months.keys.each do |month|
            amount_month = towns_data[town_code][cp][tt][month][1]/100
            row.push(towns_data[town_code][cp][tt][month][0])
            row.push(amount_month)
            sum_row += amount_month
          end
          output_data << row if sum_row > 0
        end
      end
    end

    headers = ["Comunidad Autónoma", "Provincia", "Municipio", "Círculo", "Código Postal","Territorio de Asignación"]
    send_csv_file(headers,months,output_data,"podemos.user_for_country_cp.#{Date.today.to_s}.csv")
  end

  batch_action :error_batch, if: proc{ params[:scope]=="suspects" } do |ids|
    ok = true
    Collaboration.transaction do
      Collaboration.where(id:ids).each do |c|
        ok &&= c.set_error! "Colaboración sospechosa marcada como errónea en masa"
      end
      redirect_to(collection_path, notice: "Las colaboraciones han sido marcadas como erróneas.") if ok
    end
    redirect_to(collection_path, warning: "Ha ocurrido un error y las colaboraciones no han sido marcadas como erróneas.") unless ok
  end
end