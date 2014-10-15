require 'test_helper'

class VoteControllerTest < ActionController::TestCase

  test "should not get create as anon" do
    e = FactoryGirl.create(:election)
    get :create, election_id: e.id
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales
  end

  test "should get create as user" do
    e = FactoryGirl.create(:election)
    @user = FactoryGirl.create(:user)
    sign_in @user
    get :create, election_id: e.id
    assert_response :redirect
    assert response.header["Location"].starts_with? "https://vota.podemos.info/"
  end

end
