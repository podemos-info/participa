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
    user = FactoryGirl.create(:user, :dni3)
    sign_in user
    assert_difference('Collaboration.count') do
      post :create, collaboration: { amount: 500, frequency: 12, payment_type: 1, terms_of_service: 1, minimal_year_old: 1 }
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
    debugger
    collaboration = FactoryGirl.create(:collaboration, :credit_card) 
    order = "1418300282"
    collaboration.update_attribute(:redsys_order, order)

    user = collaboration.user 
    merchant_code = "1111111111"
    Rails.application.secrets.redsys["code"] = merchant_code
    Rails.application.secrets.redsys["terminal"] = "1"
    Rails.application.secrets.redsys["secret_key"] = "1234567890"

    sign_in user
    post :redsys_callback, "user_id"=>collaboration.user.id, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>order, "Ds_MerchantCode"=>merchant_code, "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395"
    assert_response :success

    order = "1418300283"
    collaboration.update_attribute(:redsys_order, order)

    assert_raises(ActiveRecord::RecordNotFound) do
      order = "2222222"
      post :redsys_callback, "user_id"=>collaboration.user.id, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>order, "Ds_MerchantCode"=>merchant_code, "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395"
    end
  end

  test "should not get redsys_status for order as anon" do
    collaboration = FactoryGirl.create(:collaboration, :credit_card) 
    get :redsys_status, order: collaboration.redsys_order
    assert_response :redirect
    assert_redirected_to '/users/sign_in'
  end

  test "should get redsys_status for order as user" do
    collaboration = FactoryGirl.create(:collaboration, :credit_card) 
    sign_in collaboration.user
    get :redsys_status, order: collaboration.redsys_order, format: :json
    assert_response :success

    get :redsys_status, order: 22222222, format: :json
    assert_response :missing
  end

  test "should destroy collaboration" do
    sign_in @user
    assert_difference('Collaboration.count', -1) do
      delete :destroy, id: @collaboration
    end

    assert_redirected_to new_collaboration_path
  end

end
