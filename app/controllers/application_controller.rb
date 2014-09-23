class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers

  before_filter :set_phone
  before_action :set_locale
  before_filter :allow_iframe_requests

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def set_phone
    # FIXME: por cada request estamos comprobando esto, debería ser algun tipo de validación dentro
    #        de ActiveRecord after_login 
    if current_user and current_user.phone.nil? and current_user.sms_confirmed_at.nil?
      unless params[:controller] == 'sms_validator' or params[:controller] == 'devise/sessions'
        redirect_to sms_validator_step1_path
      end
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def access_denied exception
    redirect_to root_url, :alert => exception.message
  end

  def authenticate_admin_user!
    unless signed_in? && current_user.is_admin?
      redirect_to root_url, flash: { error: t('podemos.unauthorized') }
    end
  end 

end
