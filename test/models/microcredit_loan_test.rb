
require 'test_helper'

class MicrocreditLoanTest < ActiveSupport::TestCase

  setup do
    @user1 = FactoryGirl.create(:user)
    @loan = FactoryGirl.create(:microcredit_loan)
    @microcredit = FactoryGirl.create(:microcredit)
  end

  def create_loans( microcredit, number, data ) 
    (1..number.to_i).each {|n| microcredit.loans.create(data) }
  end

  test "should validation on microcredit loans work" do
    skip
    # FIXME
    # loan = MicrocreditLoan.new 
    # assert_not loan.valid?
    # assert loan.errors[:document_vatid].include? "El NIE no es válido"
    # fields = [ :first_name, :last_name, :email, :address, :postal_code, :town, :province, :country, :amount ]
    # fields.each do |field|
    #   loan.errors[field].include?("no puede estar en blanco")
    # end
  end

  test "should counted scope work" do
    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil}) 
    create_loans(@microcredit, 3, {user: @user1, amount: 100, counted_at: DateTime.now}) 
    assert_equal 3, @microcredit.loans.counted.count
  end

  test "should confirmed scope work" do
    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil}) 
    create_loans(@microcredit, 3, {user: @user1, amount: 100, counted_at: DateTime.now}) 
    create_loans(@microcredit, 4, {user: @user1, amount: 100, confirmed_at: DateTime.now}) 
    assert_equal 4, @microcredit.loans.confirmed.count
  end

  test "should phase scope work" do
    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil}) 
    create_loans(@microcredit, 3, {user: @user1, amount: 100, counted_at: DateTime.now}) 
    create_loans(@microcredit, 4, {user: @user1, amount: 100, confirmed_at: DateTime.now}) 
    assert_equal 9, @microcredit.loans.phase.count

    @microcredit.change_phase
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.loans.phase.count

    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil}) 
    assert_equal 2, @microcredit.loans.phase.count
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
    assert @loan.has_not_user?
  end

  test "should validates not passport on loans work" do
    skip
  end

  test "should validates age over on loans work" do
    skip
  end

  test "should validates check amount on microcredits loans work" do
    skip
  end

  test "should validates check user limits on microcredits loans work" do
    skip
  end

  test "should .check_microcredit_active" do
    skip
  end

  test "should .after_save work" do
    # create two unconfirmed loans: one counted and the other not
    # confirm the uncounted loan
    # the confirmed should be counted now and the other not
    skip
  end
end
