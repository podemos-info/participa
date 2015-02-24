require 'test_helper'

class ParticipationTeamsControllerTest < ActionController::TestCase

  test "should authenticate user" do
    get :index
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales
  end

  test "should get index without want_participation" do
    user = FactoryGirl.create(:user)
    sign_in user
    get :index
    assert_response :success
    assert_not_nil assigns(:participation_teams)
  end

  test "should get index with want_participation" do
    skip
  end

  test "should join a team" do
    skip
  end

  test "should leave a team" do
    skip
  end

  test "should change user circle" do
    skip
  end
end
