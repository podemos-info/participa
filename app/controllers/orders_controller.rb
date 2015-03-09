class OrdersController < ApplicationController
  protect_from_forgery except: :callback_redsys

  def callback_redsys
    request_params = params

    soap = (not request_params or not request_params["Ds_Order"])
    if soap then
      body = Hash.from_xml(request.body.string)
      xml = Hash.from_xml(body["Envelope"]["Body"]["procesaNotificacionSIS"]["XML"])
      request_params = xml["Message"]["Request"]
      request_params["Ds_Signature"] = xml["Message"]["Signature"]
    end

    redsys_order_id = request_params["Ds_Order"]
    parent = Order.parent_from_order_id redsys_order_id

    order = parent.create_order Time.now, true
    if order.first and order.is_payable?
      order.redsys_parse_response! request_params
    end
    
    if soap
      render :text => order.redsys_callback_response, :content_type => "text/xml"
    else
      render text: order.is_paid? ? "OK" : "KO"
    end
  end

end