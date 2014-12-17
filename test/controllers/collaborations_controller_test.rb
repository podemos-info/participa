require 'test_helper'

class CollaborationsControllerTest < ActionController::TestCase
  
  setup do
    @collaboration = FactoryGirl.create(:collaboration)
    @user = @collaboration.user
  end

  test "should authenticate user" do
    get :new
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales
  end

  test "should get new" do
    # TODO: should redirect if collaboration exists
    @collaboration.destroy
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create collaboration" do
    user = FactoryGirl.create(:user, :dni)
    sign_in user
    assert_difference('Collaboration.count') do
      post :create, collaboration: { amount: @collaboration.amount, frequency: @collaboration.frequency }
    end

    assert_redirected_to confirm_collaboration_path
  end

  test "should show confirm collaboration" do
    sign_in @user
    get :confirm
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit
    assert_response :success
  end

  test "should get OK" do
    sign_in @user
    get :OK
    assert_response :success
  end

  test "should get KO" do
    sign_in @user
    get :KO
    assert_response :success
  end

  test "should post callback" do
    sign_in @user
    skip("TODO")
  end

  test "should get status for order" do
    sign_in @user
    skip("TODO")
  end

  test "should destroy collaboration" do
    sign_in @user
    assert_difference('Collaboration.count', -1) do
      delete :destroy, id: @collaboration
    end

    assert_redirected_to new_collaboration_path
  end

end
