require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  setup do
    @collaboration = FactoryGirl.create(:collaboration)
    @order = @collaboration.create_order Date.today
  end

  test "should .unique_month work for Date, Time and DateTime" do 
    assert_equal( Date.civil(2013,1,1).unique_month, 24157 )
    assert_equal( Date.civil(2014,1,1).unique_month, 24169 )
    assert_equal( Date.civil(2015,1,1).unique_month, 24181 )
    assert_equal( Time.new(2013,1,1).unique_month, 24157 )
    assert_equal( Time.new(2014,1,1).unique_month, 24169 )
    assert_equal( Time.new(2015,1,1).unique_month, 24181 )
    assert_equal( DateTime.civil(2013,1,1).unique_month, 24157 )
    assert_equal( DateTime.civil(2014,1,1).unique_month, 24169 )
    assert_equal( DateTime.civil(2015,1,1).unique_month, 24181 )
    assert_equal( DateTime.civil(2015,2,1).unique_month, 24182 )
    assert_equal( DateTime.civil(2015,2,15).unique_month, 24182 )
    assert_equal( DateTime.civil(2015,2,28).unique_month, 24182 )
  end

  #test "should act_as_paranoid" do
  #  @order.destroy
  #  assert_not Order.exists?(@order.id)
  #  assert Order.with_deleted.exists?(@order.id)
  #  @order.restore
  #  assert Order.exists?(@order.id)
  #end

  test "should parent_type work" do
    assert_equal( @order.parent_type, "Collaboration" )
  end

  test "should Order.by_date work" do
    # Order.by_date(DateTime.civil(2014,1,1), DateTime.civil(2017,1,1))
    skip("TODO")
  end

  test "should Order.by_parent work" do
    skip("TODO")
  end

  test "should after_initialize set status work" do
    assert_equal( 0, @order.status )
  end

  test "should .is_payable? work" do
    @order.update_attribute(:status, 0)
    assert(@order.is_payable?)
    @order.update_attribute(:status, 1)
    assert(@order.is_payable?)
    @order.update_attribute(:status, 2)
    assert_not(@order.is_payable?)
    @order.update_attribute(:status, 3)
    assert_not(@order.is_payable?)
    @order.update_attribute(:status, 4)
    assert_not(@order.is_payable?)
  end

  test "should .is_paid? work" do
    @order.update_attribute(:payed_at, DateTime.now)
    assert(@order.is_paid?)
    @order.update_attribute(:payed_at, nil)
    assert_not(@order.is_paid?)
  end

  test "should .has_warnings? work" do
    @order.update_attribute(:status, 3)
    assert(@order.has_warnings?)
    @order.update_attribute(:status, 0)
    assert_not(@order.has_warnings?)
    @order.update_attribute(:status, 2)
    assert_not(@order.has_warnings?)
  end

  test "should .has_errors? work" do
    @order.update_attribute(:status, 0)
    assert_not @order.has_errors?
    @order.update_attribute(:status, 1)
    assert_not @order.has_errors?
    @order.update_attribute(:status, 2)
    assert_not @order.has_errors?
    @order.update_attribute(:status, 3)
    assert_not @order.has_errors?
    @order.update_attribute(:status, 4)
    assert @order.has_errors?
  end

  test "should .status_name work" do
    @order.update_attribute(:status, 0)
    assert_equal("Nueva", @order.status_name)
    @order.update_attribute(:status, 1)
    assert_equal("Sin confirmar", @order.status_name)
    @order.update_attribute(:status, 2)
    assert_equal("OK", @order.status_name)
    @order.update_attribute(:status, 3)
    assert_equal("Alerta", @order.status_name)
    @order.update_attribute(:status, 4)
    assert_equal("Error", @order.status_name)
  end

  test "should .error_message work" do
    skip("TODO")
  end

  test "should .parent_from_order_id work" do
    skip("TODO")
  end

  test "should .payment_day work" do
    skip("TODO")
  end

  test "should .by_month_count work" do
    skip("TODO")
  end

  test "should .by_month_amount work" do
    skip("TODO")
  end

  test "should .admin_permalink work" do
    puts @order.admin_permalink
    skip("TODO")
  end

  test "should .due_code work" do
    assert_equal("FRST", @order.due_code)
    order2 = @collaboration.create_order Date.today+1.month
    assert_equal("RCUR", order2.due_code)
  end

  test "should .url_source work" do
    assert_equal( "http://localhost/colabora", @order.url_source )
  end

  test "should .mark_as_charging! work" do
    @order.mark_as_charging!
    assert_equal( 1, @order.status )
  end

  test "should .mark_as_paid! work" do
    now = DateTime.now
    @order.mark_as_paid! now
    assert_equal( 2, @order.status )
    assert( @order.payed_at.is_a? Time ) 
    assert_equal( now, @order.payed_at ) 
  end

  test "should .redsys_secret work and should have all the keys" do
    %w(code name terminal secret_key identifier currency transaction_type payment_methods post_url).each do |key|
      assert( @order.redsys_secret(key).is_a? String )
    end
    assert_not( @order.redsys_secret( "blablablabla" ).is_a? String )
  end

  test "should .redsys_expiration work" do
    skip("TODO")
  end

  test "should .redsys_order_id work" do
    skip("TODO")
  end

  test "should .redsys_post_url work" do
    skip("TODO")
  end

  test "should .redsys_merchant_url work" do
    skip("TODO")
  end

  test "should .redsys_merchant_request_signature work" do
    skip("TODO")
  end

  test "should .redsys_merchant_response_signature work" do
    skip("TODO")
  end

  test "should .redsys_logger work" do
    skip("TODO")
  end

  test "should .redsys_response work" do
    skip("TODO")
  end

  test "should .redsys_parse_response work" do
    skip("TODO")
  end

  test "should .redsys_params work" do
    skip("TODO")
  end

  test "should .redsys_send_request work" do
    skip("TODO")
  end

  test "should .redsys_text_status work" do
    @order.payment_response = {"Ds_Response" => 0}
    assert_equal(@order.redsys_text_status, "Transacción autorizada para pagos y preautorizaciones")
    @order.payment_response = {"Ds_Response" => 999}
    assert_equal(@order.redsys_text_status, "Transacción denegada")
    @order.payment_response = {"Ds_Response" => 116}
    assert_equal(@order.redsys_text_status, "Disponible insuficiente")
  end

end
