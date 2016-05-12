
require_dependency Rails.root.join('app', 'controllers', 'registrations_controller').to_s

class RegistrationsController

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :email_confirmation, :password, :password_confirmation, :born_at, :wants_newsletter, :document_type, :document_vatid, :terms_of_service, :over_18, :inscription, :address, :district, :vote_town, :vote_province, :postal_code, :captcha, :captcha_key)
  end

  def new
    if Rails.application.secrets.features["allow_inscription"]
      super
    else
      redirect_to root_path, flash: { notice: 'Registrations are not open.' }
    end
  end

  def account_update_params
    if current_user.can_change_vote_location?
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :postal_code, :district, :vote_province, :vote_town)
    else
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :postal_code, :district)
    end
  end

end

