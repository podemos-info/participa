require 'test_helper'

class LegacyPasswordControllerTest < ActionController::TestCase

  setup do 
  end

  test "should not get new as anon" do
    skip("TODO")
   # get :new
   # assert_response :redirect
   # assert_redirected_to new_user_session_path, locale: :es # FIXME i18n test
   # assert_equal I18n.t('podemos.unauthorized'), flash[:error] 
  end

  test "should not redirect as user with not legacy password" do
    skip("TODO")
   # user = FactoryGirl.create(:user)
   # sign_in user
   # get :new
   # assert_response :redirect
   # assert_redirected_to authenticated_root
  end

  test "should redirect as user with legacy password" do
    skip("TODO")
  end

  test "should change the password" do
    skip("TODO")
  end

end
