require 'test_helper'

class Order
  def redsys_logger
    @@redsys_logger = Logger.new("#{Rails.root}/log/redsys_test.log")
  end
end

class OrderTest < ActiveSupport::TestCase

  setup do
    @collaboration = FactoryGirl.create(:collaboration, :ccc)
    @order = @collaboration.create_order Date.today, true
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

  test "should act_as_paranoid" do
    @order.save
    @order.destroy
    assert_not Order.exists?(@order.id)
    assert Order.with_deleted.exists?(@order.id)
    @order.restore
    assert Order.exists?(@order.id)
  end

  test "should parent_type work" do
    assert_equal( @order.parent_type, "Collaboration" )
  end

  test "should Order.by_date work" do
    @order.save
    order1 = @collaboration.create_order Date.today+10.years
    order1.save
    order2 = @collaboration.create_order Date.today+1.years
    order2.save
    orders = Order.by_date(Date.today, Date.today+5.years)
    assert_equal(2, orders.count)
  end

  test "should REDSYS_SERVER_TIME_ZONE.parse work" do
    date = Order::REDSYS_SERVER_TIME_ZONE.parse "05/03/2015 16:01"
    expected_date = DateTime.civil(2015,3,5,15,01).in_time_zone("CET")
    assert_equal(expected_date, date)
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
    assert_equal("Error", @order.error_message)
    @order.update_attribute(:status, 4)
    @order.update_attribute(:payment_type, 1)
    @order.update_attribute(:payment_response, {"Ds_Response"=> "101"}.to_json)
    assert_equal("101: Tarjeta caducada", @order.error_message)
    @order.update_attribute(:status, 5)
    assert_equal("Orden devuelta", @order.error_message)
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
    assert_equal( "/admin/orders/#{@order.id}", @order.admin_permalink )
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

  test "should .mark_as_returned! work" do
    @order.save
    @order.mark_as_returned!
    assert_equal( 5, @order.status )
  end

  test "should .mark_bank_orders_as_charged! work" do
    collaboration1 = FactoryGirl.create(:collaboration, :credit_card)
    order1 = collaboration1.create_order Date.today, true
    order1.save
    Order.mark_bank_orders_as_charged! Date.today
    order1.reload
    # shouldnt mark as charged ccc type collaboration order
    assert_equal(0, order1.status)

    # shouldnt mark as charged iban type collaboration order
    collaboration2 = FactoryGirl.create(:collaboration, :iban)
    order2 = collaboration2.create_order Date.today, true
    order2.save
    Order.mark_bank_orders_as_charged! Date.today+1.hour
    order2.reload
    assert_equal(1, order2.status)
  end

  test "should .mark_bank_orders_as_paid! work" do
    @order.save
    Order.mark_bank_orders_as_paid! Date.today
    @order.reload
    # shouldnt mark as charged ccc type collaboration order
    assert_equal(0, @order.status)

    collaboration2 = FactoryGirl.create(:collaboration, :iban)
    order2 = collaboration2.create_order Date.today, true
    order2.save

    # shouldnt mark as charged on bank no status charging
    Order.mark_bank_orders_as_paid! Date.today
    order2.reload
    assert_equal(0, order2.status)

    # should mark as charged on bank on status charging
    order2.update_attribute(:status, 1)
    Order.mark_bank_orders_as_paid! Date.today
    order2.reload
    assert_equal(2, order2.status)
  end

  test "should .redsys_secret work and should have all the keys" do
    %w(code name terminal secret_key identifier currency transaction_type payment_methods post_url).each do |key|
      assert( @order.redsys_secret(key).is_a? String )
    end
    assert_not( @order.redsys_secret( "blablablabla" ).is_a? String )
  end

  test "should .redsys_expiration work" do
    @order.payment_response = {"Ds_ExpiryDate"=>"2012"}.to_json
    @order.save
    assert_equal @order.redsys_expiration, DateTime.civil(2020,12,31,23,59,59)
  end

  test "should .redsys_order_id work" do
    # a new one
    assert_equal 12, @order.redsys_order_id.length

    # reusing Ds_Order from redsys response
    order2 = @collaboration.create_order Date.today, true
    order2_id = "000000#{order2.id}Caaaa"
    order2.payment_response = {"Ds_Order" => order2_id}.to_json
    order2.save
    assert_equal(order2_id, order2.redsys_order_id)
  end

  test "should .redsys_post_url work" do
    assert_equal( @order.redsys_post_url, Rails.application.secrets.redsys["post_url"] )
  end

  test "should .redsys_merchant_url work" do
    @order.save
    url = "https://localhost/orders/callback/redsys?parent_id=#{@order.collaboration.id}&redsys_order_id=#{@order.redsys_order_id}&user_id=#{@collaboration.user.id}"
    assert_equal url, @order.redsys_merchant_url

    @order.first = false
    @order.save
    assert_equal "", @order.redsys_merchant_url
  end

  test "should .redsys_merchant_request_signature work" do
    # FIXME: improve test
    assert_equal 40, @order.redsys_merchant_request_signature.length
  end

  test "should .redsys_merchant_response_signature work" do
    # FIXME: improve test
    @order.update_attribute(:payment_response, {"Ds_Response" => 0}.to_json)
    assert_equal 40, @order.redsys_merchant_response_signature.length
  end

  test "should .redsys_response work" do
    @order.save
    assert_equal nil, @order.redsys_response

    resp = {"Ds_Response" => 0}
    @order.payment_response = resp.to_json
    @order.save
    assert_equal resp, @order.redsys_response
  end

  test "should .redsys_parse_response! work" do
    filename = "#{Rails.root}/log/redsys_test.log"
    if File.exists? filename
      FileUtils.rm(filename)
    end
    @order.save
    @order.update_attribute(:payment_response, {"Ds_Response" => 0}.to_json)
    params = {}
    params["Ds_Response"] = 0
    #params["Ds_Response"] = 200
    params["Ds_Date"] = "05/03/2015"
    params["Ds_Hour"] = "16:01"
    params["Ds_Signature"] = @order.redsys_merchant_response_signature
    params["Ds_Merchant_Identifier"] = @order.redsys_secret("identifier")
    @order.redsys_parse_response! params
    file_contents = File.open(filename).read().split(/\n/)
    assert_equal( 1, file_contents.grep(/Redsys: New payment/).count )
    payment_info = "User: #{@collaboration.user.id} - Collaboration: #{@collaboration.id}"
    assert_equal( 1, file_contents.grep(/#{payment_info}/).count )
    assert_equal( 1, file_contents.grep(/Status: OK, but with warnings/).count )
    FileUtils.rm(filename)

  end

  test "should .redsys_send_request work" do
    # webmock for mock requests
    @order.save
    assert_equal nil, @order.payment_response
    stub_request(:post, @order.redsys_post_url).to_return(:status => 200, :body => "<!-- +(RSisReciboOK)+ -->", :headers => {})
    @order.redsys_send_request
    assert_equal "[\"RSisReciboOK\"]", @order.payment_response
  end

  test "should .redsys_text_status work" do
    # withouth payment_response
    @order.save
    assert_equal("Transacción no procesada", @order.redsys_text_status)

    # some possible payment responses
    @order.update_attribute(:payment_response, {"Ds_Response" => 0}.to_json)
    assert_equal("0: Transacción autorizada para pagos y preautorizaciones", @order.redsys_text_status)

    order1 = @collaboration.create_order Date.today+1.month, true
    order1.save
#    @order.update_attribute(:payment_response, {"Ds_Response" => 111111}.to_json)
#    assert_equal("Transacción denegada", @order.redsys_text_status)
    order1.update_attribute(:payment_response, {"Ds_Response" => 116}.to_json)
    assert_equal("116: Disponible insuficiente", order1.redsys_text_status)
  end

end
