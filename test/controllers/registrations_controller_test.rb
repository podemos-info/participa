require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  test "should show create user page" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    get :new
    assert_response :success
  end
end
