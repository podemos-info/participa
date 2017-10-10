ActiveAdmin.register_page "Envios de Credenciales" do
  breadcrumb do
    ['admin','Envíos de Credenciales']
  end
  content do
    v_count = UserVerification.not_sended.count
    if v_count > 0
      h2 "Actualmente hay #{v_count} credenciales esperando para ser enviadas."
      h2 "Generar Listado para Envío"
      form action: admin_envios_de_credenciales_generate_shipment_path, method: :get do
        div class: :filter_form_field do
          label "Número de Credenciales a Generar"
          input name: :max_reg, type: :number, placeholder:"0", value: "2000"
        end
        div class: :buttons do
          input :type => :submit, value: "Generar"
        end
      end
    else
      h2 "Actualmente no hay credenciales esperando para ser enviadas."
    end
  end

  #sidebar "Generar Listado para Envío" do

  #end

  #action_item create_shipment: "Genera Credenciales para Envío" do
  #   link_to "Generar Fichero CSV", admin_envios_de_credenciales_generate_shipment_path, method: :get
  #end

  page_action :generate_shipment, :method => :get do
    max_reg = params[:max_reg].to_i
    row_users_data={}

    us = UserVerification.not_sended.limit(max_reg).joins(:user).select('user_verifications.id', 'users.id as user_id', 'users.first_name', 'users.last_name', 'users.address', 'users.postal_code', 'users.phone', 'users.born_at').order('user_verifications.created_at ASC')
    us.each do|r|

      code = ([r.user_id].pack("L")[0..2] + Digest::CRC16.digest("#{r.user_id}-#{r.born_at}").ljust(8, "\x00")).unpack("Q").first.to_s(32).upcase
      code ="#{code[0..3]}-#{code[4..7]}"

      u = User.find(r.user_id)
      row_users_data[r.user_id] = ["#{r.user_id}","#{r.first_name.capitalize} #{r.last_name.capitalize}","#{r.first_name.capitalize}", "#{r.last_name.capitalize}",r.address, "#{r.postal_code}", " #{u.town_name}", "#{u.province_name}",r.phone,code]

      #save data

      v= UserVerification.find(r.id)
      v.update(born_at: r.born_at)
    end

    csv =CSV.generate(encoding: 'utf-8', col_sep: "\t") do |csv|
      header1 =["Id","Nombre y Apellidos","Nombre","Apellidos", "Dirección","Código Postal", "Municipio", "Provincia", "Teléfono","Código Credencial"]
      csv << header1

      row_users_data.each do |id,data|
        row=data
        csv << row
      end
    end

    send_data csv.encode('utf-8'),
              type: 'text/tsv; charset=utf-8; header=present',
              disposition: "attachment; filename=credentials_created_at_.#{Date.today.to_s}.csv"
  end

end
