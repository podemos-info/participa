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
    get :guarantees_conflict
    assert_response :success
    get :guarantees_compliance
    assert_response :success
    get :guarantees_ethic
    assert_response :success
    get :circles_validation
    assert_response :success
    get :list_register
    assert_response :redirect
    get :offer_hospitality
    assert_response :redirect
    get :find_hospitality
    assert_response :redirect
    get :share_car
    assert_response :redirect
    get :find_car
    assert_response :redirect
    get :town_legal
    assert_response :redirect
  end

  test "should get all iframes as logged in user" do
    user = FactoryGirl.create :user
    sign_in user
    get :guarantees_conflict
    assert_response :success
    get :guarantees_compliance
    assert_response :success
    get :guarantees_ethic
    assert_response :success
    get :circles_validation
    assert_response :success
    get :list_register
    assert_response :success
    get :offer_hospitality
    assert_response :success
    get :find_hospitality
    assert_response :success
    get :share_car
    assert_response :success
    get :find_car
    assert_response :success
    get :town_legal
    assert_response :success
  end

end
