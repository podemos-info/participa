class PasswordsController < Devise::PasswordsController

  # Extend devise PasswordController for a legacy user 
  # if he has a legacy password, then when updating through
  # the "Forgot your password?" should set has_legacy_password = false,
  # so we don't ask it when the user sign_in
  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    if not resource.errors.include? :password and not resource.errors.include? :password_confirmation
      resource.update_attribute(:has_legacy_password, false) if resource.has_legacy_password?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      redirect_to after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end
end
