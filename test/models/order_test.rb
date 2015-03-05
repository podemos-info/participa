require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  setup do
    @collaboration = FactoryGirl.create(:collaboration, :ccc)
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
    @order.save
    order1 = @collaboration.create_order Date.today+10.years
    order1.save
    order2 = @collaboration.create_order Date.today+1.years
    order2.save
    orders = Order.by_date(DateTime.civil(2014,1,1), DateTime.civil(2017,1,1))
    assert_equal( orders.count, 2)
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
    @order.save
    @order.update_attribute(:payed_at, DateTime.now)
    @order.update_attribute(:status, 2)
    assert(@order.is_paid?)
    @order.update_attribute(:payed_at, nil)
    assert_not(@order.is_paid?)
    @order.update_attribute(:payed_at, DateTime.now)
    @order.update_attribute(:status, 1)
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
    @order.update_attribute(:status, 0)
    assert_equal("", @order.error_message)
    @order.update_attribute(:status, 1)
    assert_equal("", @order.error_message)
    @order.update_attribute(:status, 2)
    assert_equal("", @order.error_message)
    @order.update_attribute(:status, 3)
    assert_equal("", @order.error_message)
    @order.update_attribute(:status, 4)
    @order.update_attribute(:payment_type, 2)
    assert_equal("", @order.error_message)
    #@order.update_attribute(:status, 4)
    #@order.update_attribute(:payment_type, 1)
    #@order.update_attribute(:redsys_text_status, "error")
    #assert_equal("error", @order.error_message)
    @order.update_attribute(:status, 5)
    assert_equal("Devuelta", @order.error_message)
  end

  test "should .parent_from_order_id work" do
    skip
    #@order.save
    #collaboration = Order.parent_from_order_id @order.redsys_order_id
    #assert_equal(collaboration, @collaboration)
  end

  test "should .payment_day work" do
    Rails.application.secrets.orders["payment_day"] = 10
    assert_equal(Order.payment_day, 10) 
    Rails.application.secrets.orders["payment_day"] = "10"
    assert_equal(Order.payment_day, 10) 
  end

  test "should .by_month_count work" do
    @order.save
    count = Order.by_month_count( DateTime.now )
    assert_equal(count, 1)
  end

  test "should .by_month_amount work" do
    @order.save
    amount = Order.by_month_amount( DateTime.now )
    assert_equal(amount, 10)
  end

  test "should .admin_permalink work" do
    @order.save
    assert_equal( "/admin/orders/1", @order.admin_permalink ) 
  end

  test "should .due_code work" do
    @order.first = true
    assert_equal("FRST", @order.due_code)
    @order.first = false
    assert_equal("RCUR", @order.due_code)
    @order.first = nil
    assert_equal("RCUR", @order.due_code)
  end

  test "should .url_source work" do
    assert_equal( "http://localhost/colabora", @order.url_source )
  end

  test "should .mark_as_charging work" do
    @order.mark_as_charging
    assert_equal( 1, @order.status )
  end

  test "should .mark_as_paid! work" do
    now = DateTime.now
    @order.mark_as_paid! now
    assert_equal( 2, @order.status )
    assert( @order.payed_at.is_a? Time ) 
    assert_equal( now, @order.payed_at ) 
  end

  #test "should .mark_as_returned! work" do
  #  @order.save
  #  @order.mark_as_returned!
  #  assert_equal( 5, @order.status )
  #end

  #test "should .mark_bank_orders_as_charged! work" do
  #  @order.save
  #  Order.mark_bank_orders_as_charged! Date.today
  #  assert_equal(@order.status, 1)
  #end

  #test "should .mark_bank_orders_as_paid! work" do
  #  @order.save
  #  Order.mark_bank_orders_as_paid! Date.today
  #  assert_equal(@order.status, 2)
  #end

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
    assert_equal( @order.redsys_post_url, Rails.application.secrets.redsys["post_url"] )
  end

    #test "should .redsys_merchant_url work" do
  #  @order.save
  #  puts @order.redsys_merchant_url 
  #  skip("TODO")
  #end

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

  #test "should .redsys_text_status work" do
  #  @order.save
  #  @order.payment_response = {"Ds_Response" => 0}.to_s
  #  assert_equal(@order.redsys_text_status, "Transacción autorizada para pagos y preautorizaciones")
  #  @order.payment_response = {"Ds_Response" => 999}.to_s
  #  assert_equal(@order.redsys_text_status, "Transacción denegada")
  #  @order.payment_response = {"Ds_Response" => 116}.to_s
  #  assert_equal(@order.redsys_text_status, "Disponible insuficiente")
  #end

end
