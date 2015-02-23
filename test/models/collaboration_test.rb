require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  setup do
    @collaboration = FactoryGirl.create(:collaboration)
  end

  test "should validations on collaborations work" do
    skip("TODO")
    #validates :amount, :frequency, presence: true
    #validates :terms_of_service, acceptance: true
    #validates :minimal_year_old, acceptance: true
    #validates :user_id, uniqueness: { scope: :deleted_at }, allow_nil: true, allow_blank: true
    #validates :non_user_email, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true
    #validates :non_user_document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true 
    #validate :validates_not_passport
    #validate :validates_age_over
    #validate :validates_has_user
  end 

  test "should set_initial_status work" do
    skip("TODO")
  end

  test "should .set_active work" do
    skip
  end

  test "should .validates_not_passport work" do
    skip
  end

  test "should .validates_age_over work" do
    skip
  end

  test "should .validates_ccc  work" do
    skip
  end

  test "should .validates_iban work" do
    skip
  end

  test "should .is_credit_card? work" do
    skip
  end

  test "should .is_bank_national? work" do
    skip
  end

  test "should .is_bank_international? work" do
    skip
  end

  test "should .payment_type_name work" do
    skip
  end

  test "should .frequency_name work" do
    skip
  end

  test "should .status_name work" do
    skip
  end

  test "should .ccc_full work" do 
    assert_equal "90000001210123456789", @collaboration.ccc_full
    @collaboration.ccc_dc = 5
    assert_equal "90000001050123456789", @collaboration.ccc_full
  end

  test "should .is_recurrent? work" do
    skip
  end

  test "should .is_payable? work" do
    skip
  end

  test "should .is_active? work" do
    skip
  end

  test "should .admin_permalink work" do
    skip
  end

  test "should .first_order work" do
    skip
  end

  test "should .create_order work" do
    order1 = @collaboration.create_order DateTime.now-1.month
    assert order1.save
    assert_equal(order1, @collaboration.first_order)
    assert_equal(order1.payment_type, @collaboration.payment_type)
    assert_equal(order1.amount, @collaboration.amount)
    order2 = @collaboration.create_order DateTime.now
    assert order2.save
    assert_equal(order2.payment_type, @collaboration.payment_type)
    assert_equal(order2.amount, @collaboration.amount)
  end

  test "should .payment_identifier work" do
    skip
  end

  test "should .payment_processed work" do
    skip
  end

  test "should .has_warnings? work" do
    skip
  end

  test "should .has_errors? work" do
    skip
  end

  test "should .set_warning work" do
    skip
  end

  test "should .must_have_order? work" do
    skip
  end

  test "should .get_orders work" do
    order1 = @collaboration.create_order DateTime.now-1.month
    order1.save
    order2 = @collaboration.create_order DateTime.now
    order2.save
    order3 = @collaboration.create_order DateTime.now+1.month
    order3.save
    orders = @collaboration.get_orders(DateTime.now-2.month, DateTime.now)
    assert_equal(2, orders.count)
  end

  test "should .ok_url work" do
    skip
  end

  test "should .ko_url work" do
    skip
  end

  test "should .charge! work" do
    skip
  end

  test "should .get_bank_data work" do
    skip
  end

  test "should .parse_non_user work" do
    skip
  end

  test "should .format_non_user work" do
    skip
  end

  test "should .set_non_user work" do
    skip
  end

  test "should .get_user work" do
    skip
  end

  test "should .get_non_user work" do
    skip
  end

  test "should .validates_has_user work" do
    skip
  end

  test "should .bank_filename work" do
    skip
  end

  test "should .temp_bank_filename work" do 
    skip 
  end

  test "should .has_bank_file? work" do 
    skip
  end

  test "should .generating_bank_file work" do 
    skip
  end


  ##############################################

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

  #test "should .redsys_parse_response! work" do
  #  collaboration = FactoryGirl.create(:collaboration, :credit_card)

  #  # response KO 
  #  params = {"Ds_Date"=>"27/09/2014", "Ds_Hour"=>"23:46", "Ds_SecurePayment"=>"0", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0913", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_ErrorCode"=>"SIS0051", "Ds_AuthorisationCode"=>"      "}
  #  collaboration.redsys_parse_response! params
  #  assert_equal(collaboration.redsys_response_code, "0913")
  #  assert_equal(collaboration.response_status, "KO")

  #  # response OK
  #  params = { "user_id"=>collaboration.user.id, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
  #  collaboration.redsys_parse_response! params
  #  assert_equal(collaboration.redsys_response_code, "0000")
  #  assert_equal(collaboration.response_status, "OK")

  #  # invalid user_id
  #  params = { "user_id"=>1, "collaboration_id"=>collaboration.id, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
  #  collaboration.redsys_parse_response! params
  #  assert_equal(collaboration.redsys_response_code, "0000")
  #  assert_equal(collaboration.response_status, "KO")

  #  # invalid collaboration_id
  #  params = { "user_id"=>collaboration.user.id, "collaboration_id"=>333, "Ds_Date"=>"11/12/2014", "Ds_Hour"=>"13:19", "Ds_SecurePayment"=>"1", "Ds_Card_Country"=>"724", "Ds_Amount"=>"2000", "Ds_Currency"=>"978", "Ds_Order"=>collaboration.redsys_order, "Ds_MerchantCode"=>@collaboration.redsys_secret("code"), "Ds_Terminal"=>"001", "Ds_Signature"=>collaboration.redsys_merchant_signature, "Ds_Response"=>"0000", "Ds_MerchantData"=>"", "Ds_TransactionType"=>"0", "Ds_ConsumerLanguage"=>"1", "Ds_AuthorisationCode"=>"914395" }
  #  collaboration.redsys_parse_response! params
  #  assert_equal(collaboration.redsys_response_code, "0000")
  #  assert_equal(collaboration.response_status, "KO")
  #end

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

  test "should .create_order before collection created returns false" do
    coll = FactoryGirl.create(:collaboration, :june2014)
    assert_equal coll.create_order(DateTime.new(2014,3,1)).save, false, "create_order should not consider dates previous to collaboration creation"
  end

  test "should .create_order after collection created but the same month returns false" do
    coll = FactoryGirl.create(:collaboration, created_at: DateTime.new(2014,6,10))
    assert_equal coll.create_order(DateTime.new(2014,6,5)).save, false, "create_order should not consider collaboration created after date"
    assert coll.create_order(DateTime.new(2014,6,15)).save, "create_order should consider collaboration created before date"
    coll.delete
  end

  test "should .create_order returns existing order for given period" do
    coll = FactoryGirl.create(:collaboration, :june2014)
    order = coll.create_order(DateTime.new(2014,7,15)).save
    assert order, "create_order should result a new order"
    assert_equal coll.create_order(DateTime.new(2014,7,15)), order, "create_order should return existing order"
    assert_equal coll.create_order(DateTime.new(2014,7,15)), order, "create_order should return existing order"
    coll.delete
  end

  test "should .create_order works with quarterly collaborations" do
    coll = FactoryGirl.create(:collaboration, :june2014, :quarterly)
    assert coll.create_order(DateTime.new(2014,6,15)), "create_order should return a new order for 1st month of quarterly collaboration"
    assert_nil coll.create_order(DateTime.new(2014,7,15)), "create_order should return nil for 2st month of quarterly collaboration"
    assert_nil coll.create_order(DateTime.new(2014,8,15)), "create_order should return nil for 3st month of quarterly collaboration"
    assert coll.create_order(DateTime.new(2014,9,15)), "create_order should return a new order for 4st month of quarterly collaboration"
  end

  test "should .create_order works with yearly collaborations" do
    coll = FactoryGirl.create(:collaboration, :june2014, :yearly)
    assert coll.create_order(DateTime.new(2014,6,15)), "create_order should return a new order for 1st month of yearly collaboration"
    assert_nil coll.create_order(DateTime.new(2014,7,15)), "create_order should return nil for 2nd month of yearly collaboration"
    assert coll.create_order(DateTime.new(2015,6,15)), "create_order should return a new order for 12th month of yearly collaboration"
  end

  test "should .get_orders work with collaboration created but not paid the same month" do
    skip
  end

  test "should .get_orders work after and before payment day." do
    skip
  end

  test "should .get_orders work with paid and unpaid collaborations." do
    skip
  end
end
