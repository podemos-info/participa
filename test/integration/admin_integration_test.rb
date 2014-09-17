require 'test_helper'
 
class AdminIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  test "should not get /admin as anon" do
    get '/admin'
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end

  test "should not get /admin as normal user" do
    post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password 
    get '/admin'
    assert_response :redirect
    assert_redirected_to authenticated_root_path
    assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end

  test "should get /admin as admin user" do
    post_via_redirect user_session_path, 'user[email]' => @admin.email, 'user[password]' => @admin.password 
    get '/admin'
    assert_response :success
  end

end
