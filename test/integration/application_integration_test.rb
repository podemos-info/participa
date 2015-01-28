require 'test_helper'

class ApplicationIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user)
    @user_foreign = FactoryGirl.create(:user, :foreign_address)
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

  test "should set_phone if non sms confirmed user, but allow access to profile" do
    @user.update_attribute(:sms_confirmed_at, nil)
    login @user
    assert_equal("Por seguridad, debes confirmar tu teléfono.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path, "User without confirmed phone should be redirected to verify it"
    get '/es/users/edit'
    assert_response :success, "User without confirmed phone should be allowed to access the profile page"
  end

  test "should set_new_password, set_phone and check_born_at, but allow access to profile" do 
    @user.update_attribute(:born_at, Date.civil(1900,1,1))
    @user.update_attribute(:has_legacy_password, true)
    @user.update_attribute(:sms_confirmed_at, nil)
    login @user
    assert_equal("Debes indicar tu fecha de nacimiento.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url, "User with issues should be redirected to fix them"
  end

  test "should set_new_password if legacy password, but allow access to profile" do
    @user.update_attribute(:has_legacy_password, true)
    login @user
    assert_equal("Por seguridad, debes cambiar tu contraseña.", flash[:alert])
    get "/es"
    assert_response :redirect
    assert_redirected_to new_legacy_password_path, "User with legacy password should be redirected to update it"
    get '/es/users/edit'
    assert_response :success, "User with legacy password should be allowed to access the profile page"
  end

  test "should check_born_at if born_at is null" do
    @user.update_attribute(:born_at, nil)
    login @user
    assert_equal("Debes indicar tu fecha de nacimiento.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should check_born_at if born_at 1900,1,1" do
    @user.update_attribute(:born_at, Date.civil(1900,1,1))
    login @user
    assert_equal("Debes indicar tu fecha de nacimiento.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should redirect to profile with invalid country data" do
    @user.update_attribute(:country, "España")
    login @user
    assert_equal("Debes indicar el país donde resides.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should redirect to profile with invalid province data" do
    @user.update_attribute(:province, "Madrid")
    login @user
    assert_equal("Debes indicar la provincia donde resides.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should redirect to profile with invalid town data" do
    @user.update_attribute(:town, "Madrid")
    login @user
    assert_equal("Debes indicar el municipio donde resides.", flash[:alert])
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should redirect to profile and allow to change vote town to foreign users" do
    @user_foreign.update_attribute(:vote_town, "NOTICE")
    login @user_foreign
    assert_equal("Si lo deseas, puedes indicar el municipio en España donde deseas votar.", flash[:notice])
    get '/es'
    assert_response :success
  end

  test "should redirect to profile when has has_legacy_password and invalid profile" do
    @user.update_attribute(:has_legacy_password, true)
    @user.update_attribute(:postal_code, "as")
    login @user
    get '/es'
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
  end

  test "should not redirect to profile when has invalid profile but no issues" do
    @user.update_attribute(:postal_code, "as")
    login @user
    get '/es'
    assert_response :success
  end

    
end