class RegistrationsController < Devise::RegistrationsController
  require "ffi-icu"

  prepend_before_filter :load_region_info

  def load_region_info

    # params from edit page
    @user_location = { country: params[:user_country], province: params[:user_province], town: params[:user_town] }

    # params from create page
    if params[:user]
      @user_location[:country] ||= params[:user][:country]
      @user_location[:province] ||= params[:user][:province]
      @user_location[:town] ||= params[:user][:town]
    end

    # params from user profile
    if (params[:no_profile]==nil) && current_user
      @user_location[:country] ||= current_user.country
      @user_location[:province] ||= current_user.province
      @user_location[:town] ||= current_user.town
    end

    # default country
    @user_location[:country] ||= "ES"

    # lists of countries, current country provinces and current province towns, sorted with spanish collation
    @collator = ICU::Collation::Collator.new("es_ES")
    @user_location[:countries] = Carmen::Country.all.sort {|a,b| @collator.compare(a.name, b.name)}
    @user_location[:provinces] = Carmen::Country.coded(@user_location[:country]).subregions.sort {|a,b| @collator.compare(a.name, b.name)}
    @user_location[:towns] =  if @user_location[:province] && @user_location[:country] =="ES" then
                                Carmen::Country.coded("ES").subregions.coded(@user_location[:province]).subregions.sort {|a,b| @collator.compare(a.name, b.name)}
                              else
                                []
                              end
  end

  def regions_provinces
    render partial: 'subregion_select'
  end

  def regions_municipies
    render partial: 'municipies_select'
  end

  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)

      render :new
    end
  end

  # http://www.jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html
  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :email_confirmation, :password, :password_confirmation, :born_at, :wants_newsletter, :document_type, :document_vatid, :terms_of_service, :over_18, :address, :town, :province, :postal_code, :country)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :born_at, :wants_newsletter, :address, :town, :province, :postal_code, :country)
  end

end
