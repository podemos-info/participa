require 'test_helper'

class AdminIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryBot.create(:user)
    @admin = FactoryBot.create(:user, :admin)
  end

  def login user
    post_via_redirect user_session_path, 'user[login]' => user.email, 'user[password]' => user.password 
  end

  test "should not get /admin as anon" do
    get '/admin'
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end

  test "should not get /admin/resque as anon" do
    assert_raises(ActionController::RoutingError) do
      get '/admin/resque'
    end
  end

  test "should not get /admin as normal user" do
    login @user
    get '/admin'
    assert_response :redirect
    assert_redirected_to authenticated_root_path
    assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end

  test "should not get /admin/resque as normal user" do
    login @user
    assert_raises(ActionController::RoutingError) do
      get '/admin/resque'
    end
  end

  test "should get /admin as admin user" do
    login @admin
    get '/admin'
    assert_response :success
  end

  test "should get /admin/resque as admin user" do
    login @admin
    get '/admin/resque'
    assert_response :redirect
    assert_redirected_to '/admin/resque/overview'
  end

  test "should not download newsletter CSV as user" do
    login @user
    get '/admin/users/download_newsletter_csv'
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end
    
  #test "should download newsletter CSV as admin and not download wants_newsletter = false" do
  #  login @admin
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 2, csv.count

  #  # should not change count with a no_newsletter_user
  #  FactoryBot.create(:no_newsletter_user)
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 2, csv.count

  #  # should change count with a newsletter_user
  #  FactoryBot.create(:newsletter_user)
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 3, csv.count
  #end

end
