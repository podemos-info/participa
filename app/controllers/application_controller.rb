class ApplicationController < ActionController::Base

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_phone
  before_filter :set_new_password
  before_action :set_locale
  before_filter :allow_iframe_requests
  before_filter :admin_logger

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def admin_logger
    if params["controller"].starts_with? "admin/"
      tracking = Logger.new(File.join(Rails.root, "log", "activeadmin.log"))
      if user_signed_in?
        tracking.info "** #{current_user.full_name} ** #{request.method()} #{request.path}"
      else
        tracking.info "** Anonimous ** #{request.method()} #{request.path}"
      end
      tracking.info params.to_s
      tracking.info request
    end
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_new_password
    if current_user and current_user.has_legacy_password? and current_user.sms_confirmed_at?
      unless params[:controller] == 'legacy_password' or params[:controller] == 'devise/sessions'
        redirect_to new_legacy_password_path
      end
    end
  end

  def set_phone
    # FIXME: por cada request estamos comprobando esto, debería ser algun tipo de validación dentro
    #        de ActiveRecord after_login 
    if current_user and current_user.sms_confirmed_at.nil?
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

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :document_vatid, :email, :password, :remember_me) }
  end

end
