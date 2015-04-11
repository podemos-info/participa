
require 'test_helper'

class MicrocreditTest < ActiveSupport::TestCase

  setup do
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @user3 = FactoryGirl.create(:user)
    @user4 = FactoryGirl.create(:user)
    @microcredit = FactoryGirl.create(:microcredit)
  end

  def create_loans( microcredit, number, data ) 
    (1..number.to_i).each {|n| microcredit.loans.create(data) }
  end

  test "should validation on limits on microcredits work" do
    microcredit = Microcredit.new(limits: "wrong") 
    assert_not microcredit.valid?
    assert microcredit.errors[:limits].include? "Introduce pares (monto, cantidad)"

    microcredit.limits = "100€: 100\r500€: 22\r1000€: 10"
    assert microcredit.valid?
  end

  test "should active scope work" do
    FactoryGirl.create(:microcredit, :expired)
    FactoryGirl.create(:microcredit, :expired)
    FactoryGirl.create(:microcredit, :expired)
    assert_equal 1, Microcredit.active.count
    FactoryGirl.create(:microcredit)
    FactoryGirl.create(:microcredit)
    FactoryGirl.create(:microcredit)
    assert_equal 4, Microcredit.active.count
  end

  test "should .limits getter and setter work" do 
    resp = {100=>100, 500=>22, 1000=>10}
    assert_equal resp, @microcredit.limits
    assert_equal "100€: 100\r500€: 22\r1000€: 10", @microcredit.read_attribute(:limits) 
    @microcredit.update_attribute(:limits, "10€: 10\r50€: 1\r1000€: 10")
    resp = {10=>10, 50=>1, 1000=>10}
    assert_equal resp, @microcredit.limits
  end

  test "should .parse_limits work" do 
    resp = {10000=>100, 500=>12}
    assert_equal resp, @microcredit.parse_limits("10000€: 100\r500€: 12") 
  end

  test "should .campaign_status work" do 
    create_loans(@microcredit, 7, {user: @user1, amount: 100})
    resp = []
    assert_equal resp, @microcredit.campaign_status

    # reload @microcredit
    @microcredit = Microcredit.find @microcredit.id
    resp = [[100, false, false, 7]]
    assert_equal resp, @microcredit.campaign_status

    # if loans with other limits are added, then the status should change
    create_loans(@microcredit, 2, {user: @user2, amount: 500})
    @microcredit = Microcredit.find @microcredit.id
    resp = [[100, false, false, 7], [500, false, false, 2]]
    assert_equal resp, @microcredit.campaign_status

    # if confirmed loans increase, then the status should change
    create_loans(@microcredit, 5, {user: @user3, amount: 100, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    resp = [[100, false, false, 7], [100, true, false, 5], [500, false, false, 2]]
    assert_equal resp, @microcredit.campaign_status
  end 

  test "should .phase_status work" do 
    create_loans(@microcredit, 7, {user: @user1, amount: 100})
    resp = []
    assert_equal resp, @microcredit.phase_status

    @microcredit = Microcredit.find @microcredit.id
    resp = [[100, false, false, 7]]
    assert_equal resp, @microcredit.phase_status

    @microcredit.change_phase
    @microcredit = Microcredit.find @microcredit.id
    resp = []
    assert_equal resp, @microcredit.phase_status

    create_loans(@microcredit, 3, {user: @user2, amount: 100})
    create_loans(@microcredit, 4, {user: @user3, amount: 500})
    create_loans(@microcredit, 5, {user: @user4, amount: 1000})
    create_loans(@microcredit, 2, {user: @user1, amount: 100, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    resp = [[100, false, true, 3], [100, true, false, 2], [500, false, false, 4], [1000, false, false, 5]]
    assert_equal resp, @microcredit.phase_status
  end

  test "should .remaining_percent work" do 
    skip
    # @microcredit.update_attributes(starts_at: DateTime.now, ends_at: DateTime.now+1.hour)
    # assert_equal 0, @microcredit.remaining_percent
    # @microcredit.update_attributes(starts_at: DateTime.now-1.hour, ends_at: DateTime.now+1.hour)
    # assert_equal 0.5, @microcredit.ellapsed_time_percent
    # @microcredit.update_attributes(starts_at: DateTime.now-1.hour, ends_at: DateTime.now+6.minutes)
    # assert_equal 0.9090909090909091, @microcredit.ellapsed_time_percent
  end

  test "should .has_amount_available? amount work" do 
    skip 
  # FIXME: failing test
  #  assert_nil @microcredit.has_amount_available? 10
  #  assert @microcredit.has_amount_available? 100

  #  # remove 100s 
  #  create_loans(@microcredit, 5, {user: @user1, amount: 100, confirmed_at: DateTime.now})
  #  @microcredit.limits = "100€: 5\r500€: 22\r1000€: 10"
  #  @microcredit.save
  #  @microcredit = Microcredit.find @microcredit.id
  #  assert_not @microcredit.has_amount_available? 100
  #  assert @microcredit.has_amount_available? 500
  end

  test "should .should_count? amount, confirmed work" do 
    skip 
  # FIXME: failing test
  #  assert_not @microcredit.should_count?( 100, true )
  #  assert_not @microcredit.should_count?( 100, false )
  #  create_loans(@microcredit, 10, {user: @user1, amount: 100})
  #  @microcredit = Microcredit.find @microcredit.id
  #  assert @microcredit.should_count?( 100, false )
  #  assert @microcredit.should_count?( 100, true )
  end

  test "should .phase_remaining work" do 
    skip
  end

  test "should .phase_limit_amount work" do 
    assert_equal 31000, @microcredit.phase_limit_amount

    create_loans(@microcredit, 2, {user: @user1, amount: 100})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 31000, @microcredit.phase_limit_amount

    create_loans(@microcredit, 3, {user: @user2, amount: 100})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 31000, @microcredit.phase_limit_amount

    @microcredit.change_phase 
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 31000, @microcredit.phase_limit_amount
  end

  test "should .phase_counted_amount work" do 
    assert_equal 0, @microcredit.phase_counted_amount
    create_loans(@microcredit, 3, {user: @user1, amount: 100})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 300, @microcredit.phase_counted_amount

    create_loans(@microcredit, 3, {user: @user2, amount: 500})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 2300, @microcredit.phase_counted_amount

    create_loans(@microcredit, 3, {user: @user3, amount: 500, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.phase_counted_amount

    @microcredit.change_phase 
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.phase_counted_amount
  end

  test "should .campaign_confirmed_amount work" do 
    assert_equal 0, @microcredit.campaign_confirmed_amount

    create_loans(@microcredit, 5, {user: @user1, amount: 100})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 0, @microcredit.campaign_confirmed_amount

    create_loans(@microcredit, 4, {user: @user2, amount: 100, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 400, @microcredit.campaign_confirmed_amount

    create_loans(@microcredit, 3, {user: @user3, amount: 500})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 400, @microcredit.campaign_confirmed_amount

    create_loans(@microcredit, 2, {user: @user4, amount: 500, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 1400, @microcredit.campaign_confirmed_amount
  end

  test "should .campaign_counted_amount work" do 
    assert_equal 0, @microcredit.campaign_counted_amount

    create_loans(@microcredit, 3, {user: @user1, amount: 100})
    create_loans(@microcredit, 4, {user: @user2, amount: 500})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 2400, @microcredit.campaign_counted_amount

    create_loans(@microcredit, 5, {user: @user3, amount: 500})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 2500, @microcredit.campaign_counted_amount

    create_loans(@microcredit, 2, {user: @user4, amount: 500, confirmed_at: DateTime.now})
    @microcredit = Microcredit.find @microcredit.id
    assert_equal 2500, @microcredit.campaign_counted_amount
  end

  test "should .change_phase work" do 
    assert_nil @microcredit.reset_at
    @microcredit.change_phase
    assert_not_nil @microcredit.reset_at
  end

  test "friendly id slug candidates work" do 
    now = DateTime.now
    microcredit1 = FactoryGirl.create(:microcredit, title: "Barna") 
    assert_equal("barna", microcredit1.slug)
    microcredit2 = FactoryGirl.create(:microcredit, title: "Barna") 
    assert_equal("barna-#{now.year}", microcredit2.slug)
    microcredit3 = FactoryGirl.create(:microcredit, title: "Barna") 
    assert_equal("barna-#{now.year}-#{now.month}", microcredit3.slug)
    microcredit4 = FactoryGirl.create(:microcredit, title: "Barna") 
    assert_equal("barna-#{now.year}-#{now.month}-#{now.day}", microcredit4.slug)
  end

end
