require 'test_helper'

class ParticipationTeamsControllerTest < ActionController::TestCase
  setup do
    @participation_team = participation_teams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:participation_teams)
  end

  test "should join a team" do
    skip
  end

  test "should leave a team" do
    skip
  end
end
