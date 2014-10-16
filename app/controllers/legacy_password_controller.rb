class LegacyPasswordController < ApplicationController
  before_action :authenticate_user! 
#  layout 'simple'

  # TODO: cuando el usuario cambia de contrasenia al crear la cuenta, debe hacerse un 
  # user.update_attribute(:has_legacy_password, false)
  def new
    redirect_to root_path unless current_user.has_legacy_password? 
  end

  def update
    if current_user.has_legacy_password?
      current_user.update(change_pass_params)
      if current_user.save
        current_user.update_attribute(:has_legacy_password, false)
        sign_in current_user
        redirect_to root_path, notice: t('podemos.legacy.password.changed')
      else
        render action: 'new'
      end
    else
      redirect_to root_path
    end
  end

  private
 
  def change_pass_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
