require 'test_helper'

class PageControllerTest < ActionController::TestCase
  test "should get privacy-policy" do
    get :privacy_policy
    assert_response :success
  end

end
