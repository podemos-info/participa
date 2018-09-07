require 'test_helper'

class LegacyPasswordControllerTest < ActionController::TestCase

  setup do 
  end

  test "should not get new as anon" do
    get :new
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales 
    assert_equal I18n.t('devise.failure.unauthenticated'), flash[:alert]
  end

  test "should redirect to root as user if user has not legacy password" do
    user = FactoryBot.create(:user)
    sign_in user
    get :new
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should redirect as user with legacy password" do
    user = FactoryBot.create(:user, :legacy_password_user)
    sign_in user
    get :new
    assert_response :success
  end

  test "should test if both passwords are equal" do
    user = FactoryBot.create(:user, :legacy_password_user)
    sign_in user
    post :update, user: { password: "lalalilo", password_confirmation: "error" }
    assert_response :success
    assert response.body.include? "no coincide con la confirmación" 
  end

end
