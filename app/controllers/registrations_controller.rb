class RegistrationsController < Devise::RegistrationsController

  prepend_before_filter :load_user_location

  def load_user_location
    @user_location = User.get_location(current_user, params)
  end

  def regions_provinces
    render partial: 'subregion_select', locals:{country: @user_location[:country], province: @user_location[:province], required: true, field: :province, title:"Provincia"}
  end

  def regions_municipies
    render partial: 'municipies_select', locals:{country: @user_location[:country], province: @user_location[:province], town: @user_location[:town], required: true, field: :town, title:"Municipio"}
  end

  def vote_municipies
    render partial: 'municipies_select', locals:{country: "ES", province: @user_location[:vote_province], town: @user_location[:vote_town], required: false, field: :vote_town, title:"Municipio de participación"}
  end

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)

      render :new
    end
  end

  def recover_and_logout
    current_user.send_reset_password_instructions
    sign_out_and_redirect current_user
    flash[:notice] = t("devise.confirmations.send_instructions")
  end

  def set_wants_participation
    if params[:type] == "suscribe"
      current_user.update_attribute(:wants_participation, true)
      flash[:notice] = "Te damos la bienvienida a los Equipos de Acción Participativa. En los próximos días nos pondremos en contacto contigo."
    else
      current_user.update_attribute(:wants_participation, false)
      flash[:notice] = "Te has dado de baja de los Equipos de Acción Participativa"
    end 
    redirect_to participation_teams_url
  end 

  # http://www.jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html
  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :email_confirmation, :password, :password_confirmation, :born_at, :wants_newsletter, :document_type, :document_vatid, :terms_of_service, :over_18, :address, :town, :province, :vote_town, :vote_province, :postal_code, :country)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :town, :province, :vote_town, :vote_province, :postal_code, :country)
  end

end
