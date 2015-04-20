require 'test_helper'

class MicrocreditControllerTest < ActionController::TestCase
  
  setup do
    @microcredit = FactoryGirl.create(:microcredit)
    @user = FactoryGirl.create(:user)
  end

  test "should get provinces" do 
    get :provinces
    assert_response :success
  end

  test "should get towns" do 
    get :towns
    assert_response :success
  end

  test "should get index" do 
    get :index
    assert_response :success
  end

  test "should get new_loan" do 
    get :new_loan, id: @microcredit.id
    assert_response :success
  end

  test "should post create_loan" do 
    params = {
      first_name: "juan",
      last_name: "microcred",
      document_vatid: "00000005M",
      email: "anddlala@alla.com",
      address: "C/Inventada, 123",
      postal_code: "28023",
      town: "M",
      province: "M",
      country: "ES",
      amount: 1000,
      terms_of_service: 1,
      minimal_year_old: 1,
    }
    assert_difference('MicrocreditLoan.count') do
      post :create_loan, id: @microcredit.id, microcredit_loan: params
      assert flash[:notice].include?("¡Gracias por colaborar!")
    end

    sign_in @user
    params = { amount: 1000, terms_of_service: 1, minimal_year_old: 1 }
    assert_difference('MicrocreditLoan.count') do
      post :create_loan, id: @microcredit.id, microcredit_loan: params
      assert flash[:notice].include?("¡Gracias por colaborar!")
    end
    params = { amount: 2000, terms_of_service: 1, minimal_year_old: 1 }
    assert_no_difference('MicrocreditLoan.count') do
      post :create_loan, id: @microcredit.id, microcredit_loan: params
      assert flash[:errors] && flash[:errors].include?("ya no quedan préstamos por esa cantidad")
    end

    user2 = FactoryGirl.create(:user)
    params = { amount: 100, terms_of_service: 1, minimal_year_old: 1 }
    assert_difference('MicrocreditLoan.count') do
      post :create_loan, id: @microcredit.id, microcredit_loan: params
      assert flash[:notice].include?("¡Gracias por colaborar!")
    end
    loan = MicrocreditLoan.last
    assert_equal loan.user.id, @user.id

  end

end
