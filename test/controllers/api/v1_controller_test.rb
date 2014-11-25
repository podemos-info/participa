require 'test_helper'

class Api::V1ControllerTest < ActionController::TestCase

  test "should get user_exists" do
    user = FactoryGirl.create(:user)
    get :user_exists, user: { document_vatid: user.document_vatid, email: user.email, province: user.province, town: user.town }
    assert_response :success
    get :user_exists, user: { document_vatid: "1111111111", email: user.email, province: user.province, town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, email: "lalalilo@lala.com", province: user.province, town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, email: user.email, province: "X", town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, email: user.email, province: user.province, town: "m_01_001_01" }
    assert_response :missing
  end

  test "should get user_exists case insensitive" do 
    user = FactoryGirl.create(:user)
    get :user_exists, user: { document_vatid: user.document_vatid.downcase, email: user.email.downcase, province: user.province.downcase, town: user.town.downcase }
    assert_response :success
    get :user_exists, user: { document_vatid: user.document_vatid.upcase, email: user.email.upcase, province: user.province.upcase, town: user.town.upcase }
    assert_response :success
  end

  test "should not get user_exists if params missing" do 
    user = FactoryGirl.create(:user)
    get :user_exists, user: { email: user.email, province: user.province, town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, province: user.province, town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, email: user.email, town: user.town }
    assert_response :missing
    get :user_exists, user: { document_vatid: user.document_vatid, email: user.email, province: user.province }
  end

  test "should post to registrate" do
    id = "1111111"
    post :gcm_registrate, notice_registrar: {registration_id: id}
    assert_equal id, NoticeRegistrar.find_by_registration_id(id).registration_id
    assert_equal 1, NoticeRegistrar.all.count
    post :gcm_registrate, notice_registrar: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
    post :gcm_registrate, notice_registrar: {registration_id: "2222222"}
    assert_equal 2, NoticeRegistrar.all.count
    assert_response 201
  end

end
