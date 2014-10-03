class NoticeRegistrarController < ApplicationController

  skip_before_filter :verify_authenticity_token 

  def registrate
    NoticeRegistrar.find_or_create_by(notice_registrar_params)
    render json: nil, status: 201
  end

  def unregister
  	registration = NoticeRegistrar.find(:registration_id)
  	if registration
      registration.destroy
      render json: nil, status: 200
    else
      render json: nil, status: 404
  	end
  end

  private 

  def notice_registrar_params
    params.require(:notice_registrar).permit(:registration_id)
  end
end
