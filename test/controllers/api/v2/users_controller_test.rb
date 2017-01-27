require 'test_helper'

class Api::V2::UsersControllerTest < ActionController::TestCase

  test "GET #me responds with 200" do
    token = stub(:acceptable? => true)
    user  = stub(:to_json => {})

    @controller.stubs(:doorkeeper_token).returns(token)
    @controller.stubs(:current_resource_owner).returns(user)

    get :show, format: :json
    assert_response 200
  end

  test "GET #me responds with 401 when unauthorized" do
    # See: https://github.com/doorkeeper-gem/doorkeeper/blob/master/lib/doorkeeper/models/concerns/accessible.rb
    # See: https://github.com/doorkeeper-gem/doorkeeper/blob/master/lib/doorkeeper/models/access_token_mixin.rb#L223
    token = stub(:accessible? => false, :acceptable? => false)
    user  = stub(:to_json => {})

    @controller.stubs(:doorkeeper_token).returns(token)
    @controller.stubs(:current_resource_owner).returns(user)

    get :show, format: :json
    assert_response 401
  end

  test "GET #me returns user data as json" do
    application = FactoryGirl.create(:application, scopes: 'public')
    user = FactoryGirl.create(:user)
    token = FactoryGirl.create(:access_token, application: application, resource_owner_id: user.id, scopes: 'public')

    get :show, format: :json, access_token: token.token
    assert_equal user.to_json(only: [:id, :admin, :email], methods: [:username, :full_name]), @response.body
  end

end
