class RegistrationsController < Devise::RegistrationsController
  # http://www.jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html
 
  private
 
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :born_at, :wants_newsletter, :document_type, :document_vatid, :terms_of_service)

  end
 
  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :document_type, :document_vatid)

  end
end
