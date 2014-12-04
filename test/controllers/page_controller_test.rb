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

  test "should not get guarantees as anonymous user" do
    get :guarantees
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
  end

  test "should not get guarantees as logged in user" do
    user = FactoryGirl.create :user
    sign_in user
    get :guarantees
    assert_response :success
  end

end
