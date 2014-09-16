require 'test_helper'

class SmsValidatorControllerTest < ActionController::TestCase

  test "should not get steps as anonimous" do
    get :step1
    assert_response :redirect
    get :step2
    assert_response :redirect
    get :step3
    assert_response :redirect
  end

  test "should get steps as user" do
    @user = FactoryGirl.create(:user)
    sign_in @user
    get :step1
    assert_response :success
  end

end
