require 'test_helper'

class NoticeRegistrarControllerTest < ActionController::TestCase

  test "should post to registrate" do
    id = "1111111"
    post :registrate, notice_registrar: {registration_id: id}
    assert_equal id, NoticeRegistrar.find_by_registration_id(id).registration_id
    assert_equal 1, NoticeRegistrar.all.count
    post :registrate, notice_registrar: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
    post :registrate, notice_registrar: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
  end

end
