require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  setup do 
    @collaboration = FactoryGirl.create(:collaboration)
  end

  test "should validate ccc work" do 
    skip("TODO")
    # 2177 0993 23 2366217197
    # @collaboration.
  end

  test "should validate iban work" do 
    skip("TODO")
    # ES4621770993232366217197
    # @collaboration.
  end


  test "should .merchant_currency work" do
    # codigo de euro en redsys
    assert(@collaboration.merchant_currency.is_a? Integer)
    assert_equal(978, @collaboration.merchant_currency)
  end

  test "should .merchant_code work" do
    assert(@collaboration.merchant_code.is_a? String)
    assert_equal(9, @collaboration.merchant_code.length)
  end

  test "should .merchant_terminal work" do
    assert(@collaboration.merchant_terminal.is_a? Integer)
  end

  test "should .redsys_secret_key work" do
    skip("TODO")
  end

  test "should .merchant_message work" do
    merchant_message = "#{@collaboration.amount}#{@collaboration.order}#{@collaboration.merchant_code}#{@collaboration.merchant_currency}#{@collaboration.merchant_transaction_type}#{@collaboration.merchant_url}#{@collaboration.redsys_secret_key}"
    assert_equal(merchant_message, @collaboration.merchant_message)
  end

  test ".merchant_url" do
    # TODO: check if valid url 
    # TODO: check if respoinse
    skip("TODO")
  end

  test ".match_signature" do
    skip("TODO")
  end

  test "should .parse_response work" do
    #  {"Ds_Date"=>"27/09/2014", "Ds_Hour"=>"23:46", "Ds_SecurePayment"=>"0", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>"837108c7830f", "Ds_MerchantCode"=>"054517297", "Ds_Terminal"=>"001", "Ds_Signature"=>"E86EE7730D095DFC8346C5F98E4594AD6B0565DD", "Ds_Response"=>"0913", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_ErrorCode"=>"SIS0051", "Ds_AuthorisationCode"=>"      "}
    #  {"Ds_Date"=>"27/09/2014", "Ds_Hour"=>"23:52", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>"231852dccd1e", "Ds_MerchantCode"=>"054517297", "Ds_Terminal"=>"001", "Ds_Signature"=>"22CA8B2B30C18581A57F7590AA2FC68862928D8D", "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"256385"}
    skip("TODO")
  end

  test "should .set_order work on creation" do
    skip("TODO")
  end

  test "should order be valid" do
    skip("TODO")
    # Redsys requires an order_id be provided with each transaction of a
    # specific format. The rules are as follows:
    #
    # * Minimum length: 4
    # * Maximum length: 12
    # * First 4 digits must be numerical
    # * Remaining 8 digits may be alphanumeric
  end

  test "should validate_ccc work" do 
    skip("TODO")
  end

  test "should ccc numericality work" do 
    skip("TODO")
  end

  test "should validate_iban work" do 
    skip("TODO")
  end

end
