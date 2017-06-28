require 'test_helper'

class UserVerificationsControllerTest < ActionController::TestCase
  setup do
    @user_verification = user_verifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_verifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_verification" do
    assert_difference('UserVerification.count') do
      post :create, user_verification: { author_id: @user_verification.author_id, procesed_at: @user_verification.procesed_at, result: @user_verification.result, user_id: @user_verification.user_id }
    end

    assert_redirected_to user_verification_path(assigns(:user_verification))
  end

  test "should show user_verification" do
    get :show, id: @user_verification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_verification
    assert_response :success
  end

  test "should update user_verification" do
    patch :update, id: @user_verification, user_verification: { author_id: @user_verification.author_id, procesed_at: @user_verification.procesed_at, result: @user_verification.result, user_id: @user_verification.user_id }
    assert_redirected_to user_verification_path(assigns(:user_verification))
  end

  test "should destroy user_verification" do
    assert_difference('UserVerification.count', -1) do
      delete :destroy, id: @user_verification
    end

    assert_redirected_to user_verifications_path
  end
end
