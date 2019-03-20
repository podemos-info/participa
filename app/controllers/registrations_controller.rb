class RegistrationsController < Devise::RegistrationsController

  prepend_before_filter :load_user_location
  helper_method :locked_personal_data?

  def load_user_location
    @user_location = User.get_location(current_user, params)
  end

  def regions_provinces
    # Dropdownw for AJAX on registrations edit/new
    #
    render partial: 'subregion_select', locals:{country: @user_location[:country], province: @user_location[:province], disabled: false, required: true, field: :province, title:"Provincia", options_filter:((!current_user or current_user.can_change_vote_location?) ? User.blocked_provinces : nil) }
  end

  def regions_municipies
    # Dropdownw for AJAX on registrations edit/new
    #
    render partial: 'municipies_select', locals:{country: @user_location[:country], province: @user_location[:province], town: @user_location[:town], disabled: false, required: true, field: :town, title:"Municipio"}
  end

  def vote_municipies
    # Dropdownw for AJAX on registrations edit/new
    #
    render partial: 'municipies_select', locals:{country: "ES", province: @user_location[:vote_province], town: @user_location[:vote_town], disabled: false, required: false, field: :vote_town, title:"Municipio de participación"}
  end

  def create
    build_resource(sign_up_params)
    if resource.valid_with_captcha?
      super do
        result, status = user_already_exists? resource, :document_vatid
        if status and result.errors.empty?
          UsersMailer.remember_email(:document_vatid, result.document_vatid).deliver_now
          redirect_to(root_path, notice: t("devise.registrations.signed_up_but_unconfirmed"))
          return
        end

        result, status = user_already_exists? resource, :email
        if status and result.errors.empty?
          UsersMailer.remember_email(:email, result.email).deliver_now
          redirect_to(root_path, notice: t("devise.registrations.signed_up_but_unconfirmed"))
          return
        end
      end
    else
      clean_up_passwords(resource)
      render :new
    end
  end

  def recover_and_logout
    # Allow user to reset their password from his profile
    #
    current_user.send_reset_password_instructions
    sign_out_and_redirect current_user
    flash[:notice] = t("devise.confirmations.send_instructions")
  end

  def set_flash_message(key, kind, options = {})
    options.merge! resource_params.deep_symbolize_keys
    message = find_message(kind, options)
    flash[key] = message if message.present?
  end

  private

  def locked_personal_data?
    @locked_personal_data ||= current_user && current_user.verified?
  end

  def user_already_exists?(resource, type)
    # FIX for https://github.com/plataformatec/devise/issues/3540
    # Devise paranoid only works for passwords resets.
    # With the uniqueness validation on user.document_vatid and user.email
    # it's possible to do a user listing attack.
    #
    # If the email or document_vatid are already taken we should fail
    # silently (showing the same message as an OK creation or giving an
    # error for invalid validations) and send an email to the original
    # user.
    #
    # See test/features/users_are_paranoid_test.rb
    #
    if resource.errors.added? type, :taken
      resource.errors.messages[type] -= [ t('activerecord.errors.models.user.attributes.' + type.to_s + '.taken') ]
      resource.errors.delete(type) if resource.errors.messages[type].empty?
      return resource, true
    else
      return resource, false
    end
  end

  # http://www.jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html

  def sign_up_params
    # NEVER allow setting admin, flags, sms or verification fields here
    #
    params.require(:user).permit(:first_name, :last_name, :email, :email_confirmation, :password, :password_confirmation, :born_at, :wants_newsletter, :gender, :document_type, :document_vatid, :terms_of_service, :over_18, :address, :town, :province, :vote_town, :vote_province, :postal_code, :country, :captcha, :captcha_key)
  end

  def account_update_params
    # NEVER allow setting admin, flags, sms or verification fields here

    fields = %w[email password password_confirmation current_password gender address postal_code country province town]
    fields += %w[vote_province vote_town] if current_user.can_change_vote_location?
    fields += %w[first_name last_name born_at] unless locked_personal_data?

    params.require(:user).permit(*fields)
  end

end
