require 'test_helper'

class VoteControllerTest < ActionController::TestCase

  test "should not get create as anon" do
    e = FactoryGirl.create(:election)
    get :create, election_id: e.id
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales
  end

  test "should get create as user" do
    e = FactoryGirl.create(:election, starts_at: DateTime.now-7.days, ends_at: DateTime.now+10.days)
    @user = FactoryGirl.create(:user)
    sign_in @user
    get :create, election_id: e.id
    assert_response :redirect
    assert response.header["Location"].starts_with? "https://vota.podemos.info/"
  end

  test "should give invalid date limit if election is not active" do 
    e = FactoryGirl.create(:election, starts_at: DateTime.now-30.days, ends_at: DateTime.now-7.days)
    @user = FactoryGirl.create(:user)
    sign_in @user
    get :create, election_id: e.id
    assert_not e.is_actived?
    assert_response :redirect
    assert_redirected_to root_url
    assert_equal(I18n.t('podemos.election.close_message'), flash[:error])
  end

end
