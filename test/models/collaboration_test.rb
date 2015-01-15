require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  setup do
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
    assert(collaboration.errors[:user].include? "No puedes colaborar si eres extranjero.")
  end

  test "should not save collaboration if userr is not over legal age (18 years old)" do
    user = FactoryGirl.build(:user)
    user.update_attribute(:born_at, DateTime.now-10.years)
    @collaboration.user = user
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:user].include? "No puedes colaborar si eres menor de edad.")
  end

  test "should .redsys_secret work and should have all the keys" do
    %w(code name terminal secret_key identifier currency transaction_type payment_methods post_url).each do |key|
      assert( @collaboration.redsys_secret(key).is_a? String )
    end
    assert_not( @collaboration.redsys_secret( "blablablabla" ).is_a? String )
  end

  test "should .redsys_merchant_message work" do
    skip("TODO")
  end

  test ".redsys_merchant_url" do
    # TODO: check if valid url 
    # TODO: check if respoinse
    skip("TODO")
  end

  test ".match_signature" do
    skip("TODO")
  end

  test "should .redsys_parse_response! work" do
    collaboration = FactoryGirl.create(:collaboration, :credit_card)

    # response KO 
    params = {"Ds_Date"=>"27/09/2014", "Ds_Hour"=>"23:46", "Ds_SecurePayment"=>"0", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0913", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_ErrorCode"=>"SIS0051", "Ds_AuthorisationCode"=>"      "}
    collaboration.redsys_parse_response! params
    assert_equal(collaboration.redsys_response_code, "0913")
    assert_equal(collaboration.response_status, "KO")

    # response OK
    params = { "user_id"=>collaboration.user.id, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
    collaboration.redsys_parse_response! params
    assert_equal(collaboration.redsys_response_code, "0000")
    assert_equal(collaboration.response_status, "OK")

    # invalid user_id
    params = { "user_id"=>1, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
    collaboration.redsys_parse_response! params
    assert_equal(collaboration.redsys_response_code, "0000")
    assert_equal(collaboration.response_status, "KO")

    # invalid collaboration_id
    params = { "user_id"=>collaboration.user.id, "collaboration_id"=>333, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
    collaboration.redsys_parse_response! params
    assert_equal(collaboration.redsys_response_code, "0000")
    assert_equal(collaboration.response_status, "KO")
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
