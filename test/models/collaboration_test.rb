require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  setup do 
    @collaboration = FactoryGirl.create(:collaboration)
    @user = FactoryGirl.create(:user)
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

  test "should not save collaboration if userr is not over legal age (18 years old)" do
    user = FactoryGirl.build(:user, :dni)
    user.update_attribute(:born_at, DateTime.now-10.years)
    @collaboration.user = user
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:user].include? "No puedes colaborar si eres menor de edad.")
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
    c = Collaboration.new
    c.amount = 500
    c.frequency = 3
    c.payment_type = 2
    c.ccc_entity = '2177'
    c.ccc_office = '0993'
    c.ccc_dc = '23'
    c.ccc_account = '2366217197'
    c.user = @user
    assert c.valid?

    # it should fail, DC is invalid
    c.ccc_entity = '2188'
    c.ccc_office = '0994'
    c.ccc_dc = '23'
    c.ccc_account = '216217197'
    assert_not c.valid?
    debugger
  end

  test "should ccc numericality work" do 
    c = Collaboration.new
    c.amount = 500
    c.frequency = 3
    c.payment_type = 2
    c.ccc_entity = 'AAAA'
    c.ccc_office = 'BBB'
    c.ccc_dc = 'CC'
    c.ccc_account = 'DDDDD'
    assert_not c.valid?
    assert(c.errors[:ccc_entity].include? "no es un número")
    assert(c.errors[:ccc_office].include? "no es un número")
    assert(c.errors[:ccc_dc].include? "no es un número")
    assert(c.errors[:ccc_account].include? "no es un número")
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

  test "should .generate_order before collection created returns false" do
    coll = FactoryGirl.create(:collaboration, :june2014)
    assert_equal coll.generate_order(DateTime.new(2014,3,1)), false, "generate_order should not consider dates previous to collaboration creation"
  end

  test "should .generate_order after collection created but the same month returns false" do
    coll = FactoryGirl.create(:collaboration, created_at: DateTime.new(2014,6,10))
    assert_equal coll.generate_order(DateTime.new(2014,6,5)), false, "generate_order should not consider collaboration created after date"
    assert coll.generate_order(DateTime.new(2014,6,15)), "generate_order should consider collaboration created before date"
    coll.delete
  end

  test "should .generate_order returns existing order for given period" do
    coll = FactoryGirl.create(:collaboration, :june2014)
    order = coll.generate_order(DateTime.new(2014,7,15))
    assert order, "generate_order should result a new order"
    assert_equal coll.generate_order(DateTime.new(2014,7,15)), order, "generate_order should return existing order"
    assert_equal coll.generate_order(DateTime.new(2014,7,15)), order, "generate_order should return existing order"
    coll.delete
  end

  test "should .generate_order works with quarterly collaborations" do
    coll = FactoryGirl.create(:collaboration, :june2014, :quarterly)
    assert coll.generate_order(DateTime.new(2014,6,15)), "generate_order should return a new order for 1st month of quarterly collaboration"
    assert_nil coll.generate_order(DateTime.new(2014,7,15)), "generate_order should return nil for 2st month of quarterly collaboration"
    assert_nil coll.generate_order(DateTime.new(2014,8,15)), "generate_order should return nil for 3st month of quarterly collaboration"
    assert coll.generate_order(DateTime.new(2014,9,15)), "generate_order should return a new order for 4st month of quarterly collaboration"
  end

  test "should .generate_order works with yearly collaborations" do
    coll = FactoryGirl.create(:collaboration, :june2014, :yearly)
    assert coll.generate_order(DateTime.new(2014,6,15)), "generate_order should return a new order for 1st month of yearly collaboration"
    assert_nil coll.generate_order(DateTime.new(2014,7,15)), "generate_order should return nil for 2nd month of yearly collaboration"
    assert coll.generate_order(DateTime.new(2015,6,15)), "generate_order should return a new order for 12th month of yearly collaboration"
  end
end
