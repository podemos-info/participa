class OrdersController < ApplicationController
  protect_from_forgery except: :callback_redsys

  def callback_redsys
    redsys_order_id = params["Ds_Order"]
    parent = Order.parent_from_order_id redsys_order_id

    order = parent.create_order Time.now
    order.redsys_parse_response! params
    if order.payed?
      render json: "OK"
    else
      render json: "KO"
    end
  end

end