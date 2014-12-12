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
    get :guarantees_conflict
    assert_response :success
    get :guarantees_compliance
    assert_response :success
    get :guarantees_ethic
    assert_response :success
  end

  test "should not get guarantees as logged in user" do
    user = FactoryGirl.create :user
    sign_in user
    get :guarantees_conflict
    assert_response :success
    get :guarantees_compliance
    assert_response :success
    get :guarantees_ethic
    assert_response :success
  end

end
