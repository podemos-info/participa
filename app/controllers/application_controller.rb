class ApplicationController < ActionController::Base
  ensure_security_headers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :unresolved_issues
  before_action :configure_permitted_parameters, if: :devise_controller?
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
      #tracking.info request
    end
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def after_sign_in_path_for(user)
    cookies[:cookiepolicy] = {
       :value => 'hide',
       :expires => 18.year.from_now
    }

    # reset session value
    session[:no_unresolved_issues] = false

    issue = user.get_unresolved_issue

    if issue
      # clear user validation errors if generated on issues check to avoid stop login process
      user.errors.messages.clear

      flash.delete(:notice) # remove succesfully logged message
      if issue[:message]
        issue[:message].each { |type, text| flash[type] = t("issues."+text) }
      end
      return issue[:path]
    end

    # no issues, don't check it again
    session[:no_unresolved_issues] = true

    super    
  end
  
  def unresolved_issues
    if current_user

      if session[:no_unresolved_issues]
        return nil
      end
      # get an unresolved issue, if any
      issue = current_user.get_unresolved_issue true
      if issue
        # user is in the right page to fix problem, just inform about the issue
        if params[:controller] == issue[:controller]
          if issue[:message] and request.method != "POST" # only inform in the first request of the page
            issue[:message].each { |type, text| flash.now[type] = t("issues."+text) }
          end
        # user wants to log out or edit his profile
        elsif params[:controller] == 'devise/sessions' or params[:controller] == "registrations"
        # user can't do anything else but fix the issue
        else
          redirect_to issue[:path]
        end
      else
        # when everything is OK, stop checking issues
        session[:no_unresolved_issues] = true
      end
    end
  end

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

  def user_for_papertrail
    user_signed_in? ? current_user : "Unknown user"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :document_vatid, :email, :password, :remember_me) }
  end

end
