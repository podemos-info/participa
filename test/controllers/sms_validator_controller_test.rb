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

  test "should not get steps as sms_confirmed user if already confirmed" do
    user = FactoryGirl.create(:user)
    user.update_attribute(:sms_confirmed_at, DateTime.now-1.week)
    sign_in user
    get :step1
    assert_response :redirect
    assert_redirected_to root_url 
    assert_equal "Ya has confirmado tu número en los últimos meses.", flash[:error]
  end

  test "should get steps as user" do
    user = FactoryGirl.create(:user)
    user.update_attribute(:sms_confirmed_at, nil)
    sign_in user
    get :step1
    assert_response :success

    user = FactoryGirl.create(:user)
    user.update_attribute(:sms_confirmed_at, DateTime.now-1.month)
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

  test "should set phone on step1 save it and go to step2" do
    phone = '666666666'
    sign_in @user
    post :phone, user: { unconfirmed_phone: phone } 
    @user = User.find @user.id # relaod @user data
    assert_equal "0034#{phone}", @user.unconfirmed_phone
    assert_redirected_to sms_validator_step2_path
  end

  test "should set phone on step1 on update save it as unconfirmed and go to step2" do
    phone = '666666666'
    sign_in @user
    post :phone, user: { unconfirmed_phone: phone }
    @user = User.find @user.id # relaod @user data
    assert_equal "0034#{phone}", @user.unconfirmed_phone
    assert_redirected_to sms_validator_step2_path
  end

  test "should get step2 as user with phone" do
    @user.update_attribute(:unconfirmed_phone, "0034666888999")
    sign_in @user
    get :step2 
    assert_response :success
  end

  test "should not get step2 as user with no phone" do
    @user.update_attribute(:phone, nil)
    @user.update_attribute(:unconfirmed_phone, nil)
    sign_in @user
    get :step2 
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
  end

  test "should not get step3 as user with no phone" do
    @user.update_attribute(:unconfirmed_phone, nil)
    sign_in @user
    get :step3 
    assert_response :redirect
    assert_redirected_to sms_validator_step1_path
  end

  test "should not get step3 as user with no sms_confirmation_token" do
    @user.update_attribute(:unconfirmed_phone, '0034666888999')
    @user.update_attribute(:sms_confirmation_token, nil)
    sign_in @user
    get :step3 
    assert_response :redirect
    assert_redirected_to sms_validator_step2_path
  end

  test "should confirm sms token if user give it OK" do
    token = 'AAA123'
    @user.update_attribute(:sms_confirmation_token, token)
    sign_in @user
    post :valid, user: { sms_user_token_given: token } 
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should not confirm sms token if user give it wrong" do
    token = 'AAA123'
    @user.update_attribute(:sms_confirmation_token, 'BBB123')
    sign_in @user
    post :valid, user: { sms_user_token_given: token } 
    assert_response :success
    assert_equal "El código que has puesto no corresponde con el que te enviamos por SMS.", flash[:error]
  end

  test "should change vote location from previous user when sms token if user give it OK" do
    with_blocked_change_location do
      old_user = FactoryGirl.create(:user)
      old_user.confirm!
      old_user.delete
      
      token = 'AAA123'
      new_user = FactoryGirl.create(:user, :sms_non_confirmed_user, town: "m_03_003_6", document_vatid: old_user.document_vatid, 
                                                                    sms_confirmation_token: token, unconfirmed_phone: old_user.phone)
      sign_in new_user
      post :valid, user: { sms_user_token_given: token }
      new_user = User.where(phone: old_user.phone).last
      assert_equal old_user.vote_town, new_user.vote_town, "New user vote location should be the same of the old user"
      assert_equal I18n.t("podemos.registration.message.existing_user_location"), flash[:alert]
      assert_response :redirect
      assert_redirected_to root_path
    end
  end
end
