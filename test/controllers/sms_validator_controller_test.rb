require 'test_helper'

class SmsValidatorControllerTest < ActionController::TestCase

  setup do 
    @user = FactoryGirl.create(:user, :sms_non_confirmed_user)
  end

  test "should not get steps as anonimous" do
    get :step1
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    get :step2
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    get :step3
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
  end

  test "should get steps as sms_confirmed user" do
    user = FactoryGirl.create(:user)
    sign_in user
    get :step1
    assert_response :success
  end

  test "should redirect to steps as non sms_confirmed_user" do
    sign_in @user
    @controller = ToolsController.new
    get :index
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
  end

  test "should set phone on step1, save it and go to step2" do
    phone = '0034668892522'
    sign_in @user
    post :phone, user: { phone: phone } # FIXME
    assert_equal phone, @user.phone
    assert_redirected_to sms_validator_step2_path
  end

  test "should get step2 as user with phone" do
    @user.update_attribute(:phone, "0034666888999")
    sign_in @user
    get :step2 
    assert_response :success
  end

  test "should not get step2 as user with no phone" do
    sign_in @user
    get :step2 
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
  end

  test "should not get step3 as user with no phone" do
    sign_in @user
    get :step3 
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
  end

  test "should not get step3 as user with no sms_confirmation_token" do
    @user.update_attribute(:phone, '0034666888999')
    sign_in @user
    get :step3 
    assert_response :redirect
    assert_redirected_to sms_validator_step2_path
  end

  test "should validate captcha" do
    skip("TODO")
  end

  test "should confirm sms token if user give it OK" do
    skip("TODO")
  end

  test "should not confirm sms token if user give it wrong" do
    skip("TODO")
  end

end
