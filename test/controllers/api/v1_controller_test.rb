require 'test_helper'

class Api::V1ControllerTest < ActionController::TestCase

  test "should post to registrate" do
    id = "1111111"
    post :gcm_registrate, v1: {registration_id: id}
    assert_equal id, NoticeRegistrar.find_by_registration_id(id).registration_id
    assert_equal 1, NoticeRegistrar.all.count
    post :gcm_registrate, v1: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
    post :gcm_registrate, v1: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
  end

end
