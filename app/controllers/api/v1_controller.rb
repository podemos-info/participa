class Api::V1Controller < ApplicationController

  skip_before_filter :verify_authenticity_token 

  def user_exists
   if User.exists?(user_exists_params)
      render json: nil, status: 200
   else
      render json: nil, status: 404
   end
  end

  def gcm_registrate
    NoticeRegistrar.find_or_create_by(gcm_params)
    render json: nil, status: 201
  end

  def gcm_unregister
  	registration = NoticeRegistrar.find(:registration_id)
  	if registration
      registration.destroy
      render json: nil, status: 200
    else
      render json: nil, status: 404
  	end
  end

  private 

  def gcm_params
    params.require(:notice_registrar).permit(:registration_id)
  end

  def user_exists_params
    params.require(:user).permit(:document_vatid, :email, :province, :town)
  end

end
