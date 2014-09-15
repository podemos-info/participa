require 'test_helper'

class ToolsControllerTest < ActionController::TestCase

  test "should not get index as anonimous" do
    get :index
    assert_response :redirect
  end

  test "should get index as user" do
    @user = FactoryGirl.create(:user)
    sign_in @user
    get :index
    assert_response :success
  end

end
