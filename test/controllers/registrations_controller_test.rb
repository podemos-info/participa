require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  setup do 
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user)
  end

  test "should show create user page" do
    get :new
    assert_response :success
  end

  test "should success when visits profile" do
    sign_in @user
    
    get :edit
    assert_response :success
  end

  test "should success when visits profile with more than 3 months phone confirmation date" do
    @user.update_attribute(:confirmed_at, Date.civil(2014, 1, 1))
    @user.update_attribute(:sms_confirmed_at, Date.civil(2014, 1, 1))
    sign_in @user
    
    get :edit
    assert_response :success
  end


end
