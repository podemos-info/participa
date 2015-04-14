class RegistrationsController < Devise::RegistrationsController

  prepend_before_filter :load_user_location

  def load_user_location
    @user_location = User.get_location(current_user, params)
  end

  def regions_provinces
    render partial: 'subregion_select', locals:{country: @user_location[:country], province: @user_location[:province], disabled: false, required: true, field: :province, title:"Provincia", options_filter:(current_user.can_change_vote_location? ? User.blocked_provinces : nil) }
  end

  def regions_municipies
    render partial: 'municipies_select', locals:{country: @user_location[:country], province: @user_location[:province], town: @user_location[:town], disabled: false, required: true, field: :town, title:"Municipio"}
  end

  def vote_municipies
    render partial: 'municipies_select', locals:{country: "ES", province: @user_location[:vote_province], town: @user_location[:vote_town], disabled: false, required: false, field: :vote_town, title:"Municipio de participación"}
  end
  
  def create
    if verify_recaptcha
      super do 
        if resource.apply_previous_user_vote_location
          flash[:alert] = t("podemos.registration.message.existing_user_location")
        end
      end 
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

  def set_flash_message(key, kind, options = {})
    options.merge! resource_params.deep_symbolize_keys
    message = find_message(kind, options)
    flash[key] = message if message.present?
  end
  
  # http://www.jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html
  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :email_confirmation, :password, :password_confirmation, :born_at, :wants_newsletter, :document_type, :document_vatid, :terms_of_service, :over_18, :address, :town, :province, :vote_town, :vote_province, :postal_code, :country)
  end

  def account_update_params
    if current_user.can_change_vote_location?
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :postal_code, :country, :province, :town, :vote_province, :vote_town)
    else
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :postal_code, :country, :province, :town)
    end
  end

end
