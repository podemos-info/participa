
require 'test_helper'

class MicrocreditLoanTest < ActiveSupport::TestCase

  setup do
    @user1 = FactoryBot.create(:user)
    @loan = FactoryBot.create(:microcredit_loan)
    @microcredit = FactoryBot.create(:microcredit)
  end

  def create_loans( microcredit, number, data, update_counted=true )
    (1..number.to_i).each do |n|
      loan = microcredit.loans.create(data)

      loan.update_counted_at if update_counted
    end
  end

  test "should validation on microcredit loans work" do
    loan = MicrocreditLoan.new
    loan.microcredit = @microcredit
    loan.set_user_data( { email: "ejemplo@example.com" })
    assert_not loan.valid?
    assert loan.errors[:document_vatid].include? "is invalid"
    fields = [ :first_name, :last_name, :address, :postal_code, :town, :province, :country, :amount ]
    fields.each do |field|
     loan.errors[field].include?("no puede estar en blanco")
    end
  end

  test "should counted scope work" do
    create_loans(@microcredit, 5, {user: @user1, amount: 1000})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.loans.counted.count

    create_loans(@microcredit, 5, {user: @user1, amount: 1000, counted_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 5, @microcredit.loans.counted.count

    create_loans(@microcredit, 5, {user: @user1, amount: 100, counted_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 5, @microcredit.loans.counted.count
  end

  test "should confirmed scope work" do
    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil})
    create_loans(@microcredit, 3, {user: @user1, amount: 100, counted_at: DateTime.now})
    create_loans(@microcredit, 4, {user: @user1, amount: 100, confirmed_at: DateTime.now})
    assert_equal 4, @microcredit.loans.confirmed.count
  end

  test "should phase scope work" do
    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil})
    create_loans(@microcredit, 3, {user: @user1, amount: 100, counted_at: DateTime.now-1.day})
    create_loans(@microcredit, 4, {user: @user1, amount: 100, confirmed_at: DateTime.now-1.day})
    assert_equal 9, @microcredit.loans.phase.count

    @microcredit.change_phase!
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.loans.phase.count

    create_loans(@microcredit, 2, {user: @user1, amount: 100, counted_at: nil})
    assert_equal 2, @microcredit.loans.phase.count
  end

  test "should after_initialize user work" do
    loan = FactoryBot.create(:microcredit_loan, user: @user1)
    assert_equal loan.user, @user1
    #assert_equal loan.document_vatid, @user1.document_vatid
    # TODO: set_user_data on after_initialize
  end

  test "should .set_user_data work" do
    microcredit_loan = MicrocreditLoan.new
    microcredit_loan.set_user_data( {
      first_name: "Pepito",
      last_name: "Peres",
      email: "ejemplo@example.com",
      address: "C/Inven 123",
      postal_code: "28012",
      town: "Madrid",
      province: "Madrid",
      country: "ES"
    })
    microcredit_loan
  end

  test "should .has_not_user? work" do
    assert_not @loan.has_not_user?
    @loan.user = nil
    assert @loan.has_not_user?
  end

  test "should validates not passport on loans work" do
    @user1.document_type = 3
    @user1.save
    microcredit_loan = FactoryBot.build(:microcredit_loan, user: @user1)
    assert_not microcredit_loan.valid?
    error = "No puedes suscribir un microcrédito si no dispones de DNI o NIE."
    assert_equal error, microcredit_loan.errors.messages[:user].first
  end

  test "should validates age over on loans work" do
    @user1.born_at = DateTime.now-17.years
    @user1.save
    microcredit_loan = FactoryBot.build(:microcredit_loan, user: @user1)
    assert_not microcredit_loan.valid?
    error = "No puedes suscribir un microcrédito si eres menor de edad."
    assert_equal error, microcredit_loan.errors.messages[:user].first
  end

  test "should validates check amount on microcredits loans work" do
    @microcredit.limits = "100€: 5\r500€: 10"
    @microcredit.save
    create_loans(@microcredit, 5, {user: @user1, amount: 100, counted_at: DateTime.now, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    loan = MicrocreditLoan.create(microcredit: @microcredit, user: @user1, amount: 100, counted_at: DateTime.now, confirmed_at: DateTime.now)
    assert loan.valid?
  end

  test "should validates check user limits on microcredits loans work" do
    create_loans(@microcredit, 15, {user: @user1, amount: 100})
    loan = MicrocreditLoan.create(microcredit: @microcredit, user: @user1, amount: 100, counted_at: DateTime.now, confirmed_at: DateTime.now)
    assert_not loan.valid?
    error = "Lamentablemente, no es posible suscribir este microcrédito."
    assert_equal error, loan.errors.messages[:user].first
  end

  test "should .check_microcredit_active" do
    @microcredit.ends_at = DateTime.now-1.day
    @microcredit.save
    data = {user: @user1, amount: 100, counted_at: nil}
    loan = @microcredit.loans.create(data)
    assert_not loan.valid?
    error = "La campaña de microcréditos no está activa en este momento."
    assert_equal error, loan.errors.messages[:microcredit].first
  end

  test "should .after_save work" do
    # this test should check 6 cases:
    # - create a loan at the beginning of the campaign, that should be counted
    # - create a loan at the end of the campaign, that should not be counted
    # - confirm a counted loan, that should not do anything else
    # - confirm an uncounted loan without any other loan, that should count the loan
    # - confirm an uncounted loan with an older unconfirmed and counted loan, that should transfer the count to the confirmed one
    # - confirm an uncounted loan with the phase out of stock of the loan amount, that should not do anything else

    # Ending campaign
    microcredit = FactoryBot.create(:microcredit)
    microcredit.starts_at = DateTime.now-3.month
    microcredit.ends_at = DateTime.now+10.minute
    microcredit.save

    l1 = microcredit.loans.create user: @user1, amount: 100, counted_at: DateTime.now
    l2 = microcredit.loans.create user: @user1, amount: 100, counted_at: nil

    l2.confirmed_at = DateTime.now
    l2.update_counted_at

    # reload l1 from database
    l1 = MicrocreditLoan.find(l1.id)

    assert_not_nil l2.counted_at, "Confirmed loans should be counted now"
    assert_nil l1.counted_at, "Unconfirmed loans should not be counted now"
  end
end
