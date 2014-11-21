require 'test_helper'

class ApplicationIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user)
  end

  def login user
    post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password 
  end

  test "should default_url_options locale" do
    get '/'
    assert_response :redirect
    assert_redirected_to '/es'
  end

  test "should set_locale" do
    get '/ca'
    assert_equal(:ca, I18n.locale)
    get '/eu'
    assert_equal(:eu, I18n.locale)
  end

  test "should success when login with a foreign user" do
    @user.update_attribute(:country, "DE")
    @user.update_attribute(:province, "BE")
    @user.update_attribute(:town, "Berlin")
    login @user
    get '/es'
    assert_response :success
  end

  test "should success when login with a rare foreign user (no provinces)" do
    @user.update_attribute(:country, "PS")
    @user.update_attribute(:province, "Cisjordania")
    @user.update_attribute(:town, "Belén")
    login @user
    
    get '/es'
    assert_response :success
  end

  test "should set_phone if non sms confirmed user" do
    @user.update_attribute(:sms_confirmed_at, nil)
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
    assert_equal("Debes confirmar tu teléfono para poder continuar.", flash[:notice])
  end

  test "should set_new_password, set_phone and check_born_at" do 
    @user.update_attribute(:has_legacy_password, true)
    @user.update_attribute(:sms_confirmed_at, nil)
    @user.update_attribute(:born_at, Date.civil(1900,1,1))
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
    assert_equal("Debes confirmar tu teléfono para poder continuar.", flash[:notice])
  end

  test "should set_new_password if legacy password" do
    @user.update_attribute(:has_legacy_password, true)
    login @user
    get "/es"
    assert_response :redirect
    assert_redirected_to new_legacy_password_path
    assert_equal("Debes cambiar tu contraseña para poder continuar.", flash[:notice])
  end

  test "should check_born_at if born_at 1900,1,1" do
    @user.update_attribute(:born_at, Date.civil(1900,1,1))
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
    assert_equal("Debes indicar tu fecha de nacimiento para poder continuar.", flash[:notice])
  end

  test "should redirect to profile with invalid country data" do
    @user.update_attribute(:country, "España")
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
    assert_equal("Debes indicar el país donde resides para poder continuar.", flash[:notice])
  end

  test "should redirect to profile with invalid province data" do
    @user.update_attribute(:province, "Madrid")
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
    assert_equal("Debes indicar la provincia donde resides para poder continuar.", flash[:notice])
  end

  test "should redirect to profile with invalid town data" do
    @user.update_attribute(:town, "Madrid")
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
    assert_equal("Debes indicar el municipio donde resides para poder continuar.", flash[:notice])
  end

end