class Api::V1Controller < ApplicationController

  skip_before_filter :verify_authenticity_token 

  def user_exists
    exists = false
    document_vatid = params[:user][:document_vatid]
    email = params[:user][:email]
    province = params[:user][:province]
    town = params[:user][:town]
    island = params[:user][:island]
    autonomy = params[:user][:autonomy]
    foreign = params[:user][:foreign]
    if document_vatid and email
      t = User.arel_table
      user = User.where("lower(email) = ? AND lower(document_vatid) = ?", email.downcase, document_vatid.downcase).take
      if user
        exists = 
              if province and town
                user.province.casecmp(province)==0 and user.town.casecmp(town)==0
              elsif autonomy
                user.autonomy_code.casecmp(autonomy)==0
              elsif island
                user.island_code.casecmp(island)==0
              elsif foreign
                user.country != "ES"
              end
      end
    end

    if exists
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
    params.require(:v1).permit(:registration_id)
  end

end
