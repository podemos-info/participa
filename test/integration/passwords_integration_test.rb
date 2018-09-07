require 'test_helper'

class PasswordsIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryBot.create(:user)
    @legacy_password_user = FactoryBot.create(:user, :legacy_password_user)
  end

  def login user
    post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password 
  end

  test "should login with password as user" do
    login @user
    get '/es'
    assert_response :success
  end

  test "should login with legacy password and change it as legacy_password_user" do
    login @legacy_password_user
    get '/es'
    assert_response :redirect
    assert_redirected_to new_legacy_password_path
  end

  test "should not have legacy password if legacy_password_user changes it through devise" do
    password = 'lalalilo'
    put "/es/users/password", user: {reset_password_token: @legacy_password_user.reset_password_token, password: password, password_confirmation: password} 
    post_via_redirect user_session_path, 'user[email]' => @legacy_password_user.email, 'user[password]' => password 
    get '/es'
    assert_response :success
  end

end
