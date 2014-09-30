require 'test_helper'

class NoticeRegistrarControllerTest < ActionController::TestCase
  test "should get registrate" do
    get :registrate
    assert_response :success
  end

end
