require 'test_helper'

class PageControllerTest < ActionController::TestCase

  test "should get privacy-policy" do
    get :privacy_policy
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end
  
  test "should only get not auth iframes as anonymous user" do
    get :circles_validation
    assert_response :success
    get :list_register
    assert_response :redirect
    get :town_legal
    assert_response :redirect
  end

  test "should get all iframes as logged in user" do
    user = FactoryGirl.create :user
    sign_in user
    get :circles_validation
    assert_response :success
    get :list_register
    assert_response :success
    get :town_legal
    assert_response :success
  end

  test "should get credits_info as anonymous user" do
    user = FactoryGirl.create :user
    sign_in user
    get :credits_info
    assert_response :success
  end

  test "should get credits_info as logged in user" do
    user = FactoryGirl.create :user
    sign_in user
    get :credits_info
    assert_response :success
  end

end
