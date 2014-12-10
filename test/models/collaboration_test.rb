require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  def setup
    @collaboration = FactoryGirl.create(:collaboration)
  end

  test "should .ccc_full work" do 
    assert_equal "9000 0001 21 0123456789", @collaboration.ccc_full
    @collaboration.ccc_dc = 5
    assert_equal "9000 0001 05 0123456789", @collaboration.ccc_full
  end

  test "should not save collaboration if foreign user (passport)" do
    collaboration = FactoryGirl.build(:collaboration, :foreign_user)
    assert_not collaboration.valid?
    # assert @collaboration.errors[:user] 
  end

  test "should .redsys_merchant_currency work" do
    # codigo de euro en redsys
    assert(@collaboration.redsys_merchant_currency.is_a? Integer)
    assert_equal(978, @collaboration.redsys_merchant_currency)
  end

  test "should .redsys_merchant_code work" do
    assert(@collaboration.redsys_merchant_code.is_a? String)
    assert_equal(9, @collaboration.redsys_merchant_code.length)
  end

  test "should .redsys_merchant_terminal work" do
    assert(@collaboration.redsys_merchant_terminal.is_a? String)
  end

  test "should .redsys_secret_key work" do
    skip("TODO")
  end

  test "should .redsys_merchant_message work" do
    merchant_message = "#{@collaboration.amount}#{@collaboration.redsys_order}#{@collaboration.redsys_merchant_code}#{@collaboration.redsys_merchant_currency}#{@collaboration.redsys_merchant_transaction_type}#{@collaboration.redsys_merchant_url}#{@collaboration.redsys_secret_key}"
    assert_equal(merchant_message, @collaboration.redsys_merchant_message)
  end

  test ".redsys_merchant_url" do
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

  test "should .validate_ccc work" do 
    @collaboration.payment_type = 2
    @collaboration.ccc_entity = '2177'
    @collaboration.ccc_office = '0993'
    @collaboration.ccc_dc = '23'
    @collaboration.ccc_account = '2366217197'
    assert @collaboration.valid?

    # it should fail, DC is invalid
    @collaboration.ccc_entity = '2188'
    @collaboration.ccc_office = '0994'
    @collaboration.ccc_dc = '11'
    @collaboration.ccc_account = '216217197'
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:ccc_dc].include? "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
  end

  test "should ccc numericality work" do 
    @collaboration.payment_type = 2
    @collaboration.ccc_entity = 'AAAA'
    @collaboration.ccc_office = 'BBB'
    @collaboration.ccc_dc = 'CC'
    @collaboration.ccc_account = 'DDDDD'
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:ccc_entity].include? "no es un número")
    assert(@collaboration.errors[:ccc_office].include? "no es un número")
    assert(@collaboration.errors[:ccc_dc].include? "no es un número")
    assert(@collaboration.errors[:ccc_account].include? "no es un número")
  end

  test "should validate_iban work" do 
    @collaboration.payment_type = 3
    @collaboration.iban_account = "ES4621770993232366217197"
    @collaboration.iban_bic = "XXXXXX"
    assert @collaboration.valid?

    @collaboration.iban_account = "ES4621770993232366222222"
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:iban_account].include? "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
  end

end
