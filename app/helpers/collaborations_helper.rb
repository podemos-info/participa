module CollaborationsHelper

  def new_or_edit_collaboration_path(collaboration)
    collaboration ? edit_collaboration_path : new_collaboration_path
  end

  def number_to_euro(amount)
    number_to_currency(amount/100.0, unit: "€", format: "%n %u")
  end

  def show_redsys_response(status)
    # Given a status code, returns the status message
    case status.to_i
    when 0..99      then "Transacción autorizada para pagos y preautorizaciones"
    when 900        then "Transacción autorizada para devoluciones y confirmaciones"
    when 101        then "Tarjeta caducada"
    when 102        then "Tarjeta en excepción transitoria o bajo sospecha de fraude"
    when 104, 9104  then "Operación no permitida para esa tarjeta o terminal"
    when 116        then "Disponible insuficiente"
    when 118        then "Tarjeta no registrada"
    when 129        then "Código de seguridad (CVV2/CVC2) incorrecto"
    when 180        then "Tarjeta ajena al servicio"
    when 184        then "Error en la autenticación del titular"
    when 190        then "Denegación sin especificar Motivo"
    when 191        then "Fecha de caducidad errónea"
    when 202        then "Tarjeta en excepción transitoria o bajo sospecha de fraude con retirada de tarjeta"
    when 912, 9912  then "Emisor no disponible"
    else
      "Transacción denegada"
    end
  end

end
