
require 'test_helper'

class MicrocreditTest < ActiveSupport::TestCase

  setup do
    @microcredit = FactoryGirl.create(:microcredit)
  end

  test "should validation on limits on microcredits work" do
    microcredit = Microcredit.new(limits: "wrong") 
    assert_not microcredit.valid?
    assert microcredit.errors[:limits].include? "Introduce pares (monto, cantidad)"

    microcredit.limits = "100€: 100\r500€: 22\r1000€: 10"
    assert microcredit.valid?
  end

  test "should current scope work" do
    expired = FactoryGirl.create(:microcredit, :expired)
    assert_equal 1, Microcredit.current.count
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

  test "should .current_remaining work" do 
    assert_equal [[100, 100], [500, 22], [1000, 10]], @microcredit.current_remaining
  end

  test "should .current_lent work" do 
    assert_equal 0, @microcredit.current_lent
  end

  test "should .current_confirmed work" do 
    assert_equal 0, @microcredit.current_confirmed
  end

  test "should .current_limit work" do 
    assert_equal 31000, @microcredit.current_limit
  end

  test "should .total_lent work" do 
    assert_equal 0, @microcredit.total_lent
  end

  test "should .total_confirmed work" do 
    assert_equal 0, @microcredit.total_confirmed
  end

  test "should .change_phase work" do 
    assert_nil @microcredit.reset_at
    @microcredit.change_phase
    assert @microcredit.reset_at
  end

end
