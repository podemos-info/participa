class LegacyPasswordController < ApplicationController
  before_action :authenticate_user! 
  layout 'simple'

  def new
    unless current_user.has_legacy_password? 
      redirect_to root_path
    else
      redirect_to authenticated_root_path
    end
  end

  def update
    if current_user.has_legacy_password?
      current_user.password = params[:password]
      current_user.password_confirmation = params[:password_confirmation]
      if current_user.save
        current_user.update_attribute(:has_legacy_password, false)
        redirect_to root_path, notice: t('podemos.legacy.password.changed')
      else
        render new
      end
    end
  end

end
