class SmsValidatorController < ApplicationController
  before_action :authenticate_user! 

  # GET /validator/step1
  # POST /validator/phone
  def step1
    if params[:user]
      current_user.update_attribute(:phone, params[:user][:phone])
      if current_user.valid?
        current_user.set_sms_token!
        redirect_to sms_validator_step2_path
      end
    end
  end

  # GET /validator/step2
  def step2
    @user = current_user
    # TODO: check if phone number is saved, if not goback to step1
    #redirect_to sms_validator_step1_path if current_user.phone.nil?
  end

  # GET /validator/step3
  def step3
    # TODO: check if phone number is saved, if not goback to step1
    # TODO: check if there is an SMS token, if not goback to step2
    # TODO: check and validate SMS token with input
    # if current_user.phone.nil? redirect_to sms_validator_step1_path
    # if current_user.sms_confirmation_token.nil? redirect_to sms_validator_step2_path
    @user = current_user
    render action: "step3"
  end

  # POST /validator/captcha
  def captcha 
    if simple_captcha_valid? 
      current_user.send_sms_token!
      render action: "step3"
    else
      flash.now[:error] = "Captcha invalido"
      render action: "step2"
    end
  end

  # POST /validator/captcha
  def valid
    if current_user.check_sms_token(params[:sms_token][:sms_user_token])
      flash.now[:notice] = "Has validado correctamente."
      redirect_to authenticated_root_path
    else
      flash.now[:error] = "El código que has puesto no corresponde con el que te enviamos por SMS."
      render action: "step3"
    end
  end

end
