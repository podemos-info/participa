class Api::V1Controller < ApplicationController

  skip_before_filter :verify_authenticity_token 

  def user_exists
    document_vatid = params[:user][:document_vatid]
    email = params[:user][:email]
    province = params[:user][:province]
    town = params[:user][:town]
    if document_vatid and email and province and town 
      t = User.arel_table
      if User.where(t[:email].matches(email)).where(t[:document_vatid].matches(document_vatid)).where(t[:town].matches(town)).where(t[:province].matches(province)).exists?
        render json: nil, status: 200
      else
        render json: nil, status: 404
      end
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
    params.require(:v1).permit(:registration_id)
  end

end
