
require 'test_helper'

class MicrocreditLoanTest < ActiveSupport::TestCase

  setup do
    @loan = FactoryGirl.create(:microcredit_loan)
  end

  test "should validation on microcredit loans work" do
    loan = MicrocreditLoan.new 
    assert_not loan.valid?
    assert loan.errors[:document_vatid].include? "El NIE no es válido"
    fields = [ :first_name, :last_name, :email, :address, :postal_code, :town, :province, :country, :amount ]
    fields.each do |field|
      loan.errors[field].include?("no puede estar en blanco")
    end
  end

  test "should current scope work" do
    expired = FactoryGirl.create(:microcredit_loan, :expired)
    assert_equal 1, MicrocreditLoan.current.count
  end

  test "should after_initialize user work" do 
    skip
  end

  test "should .set_user_data work" do 
    skip
  end

  test "should .has_not_user? work" do 
    assert_not @loan.has_not_user?
    @loan.user = nil
    @load.user_data = ""
    assert @loan.has_not_user?
  end

end
