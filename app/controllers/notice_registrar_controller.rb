class NoticeRegistrarController < ApplicationController

  skip_before_filter :verify_authenticity_token 

  def registrate
    NoticeRegistrar.find_or_create_by(notice_registrar_params)
  end

  private 

  def notice_registrar_params
    params.require(:notice_registrar).permit(:registration_id)
  end

end
