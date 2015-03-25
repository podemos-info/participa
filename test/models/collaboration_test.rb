require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase

  setup do
    @collaboration = FactoryGirl.create(:collaboration, :ccc)
  end

  test "should validations on collaborations work" do
    c = Collaboration.new
    assert_not c.save
    assert(c.errors[:amount].include? "no puede estar en blanco")
    assert(c.errors[:frequency].include? "no puede estar en blanco")
    #assert(c.errors[:terms_of_service].include? "debes aceptar.")
    #assert(c.errors[:minimal_year_old].include? "debes aceptar.")
    #validates :user_id, uniqueness: { scope: :deleted_at }, allow_nil: true, allow_blank: true
    #validates :non_user_email, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true
    #validates :non_user_document_vatid, uniqueness: {case_sensitive: false, scope: :deleted_at }, allow_nil: true, allow_blank: true 
    #validate :validates_age_over
    #validate :validates_has_user
  end 

  test "should set_initial_status work" do
    assert_equal( @collaboration.status, 0 ) 
    c = Collaboration.new
    c.save
    assert_equal c.status, 0
  end

  test "should .set_active work" do
    @collaboration.update_attribute(:status, 0)
    @collaboration.set_active 
    assert_equal( 2, @collaboration.status)
    @collaboration.update_attribute(:status, 1)
    @collaboration.set_active 
    assert_equal( 2, @collaboration.status)
    @collaboration.update_attribute(:status, 3)
    @collaboration.set_active 
    assert_equal( 3, @collaboration.status)
    @collaboration.update_attribute(:status, 4)
    @collaboration.set_active 
    assert_equal( 4, @collaboration.status)
  end

  test "should .validates_not_passport work" do
    collaboration = FactoryGirl.build(:collaboration, :foreign_user)
    assert_not collaboration.valid?
    assert(collaboration.errors[:user].include? "No puedes colaborar si no dispones de DNI o NIE.")
  end

  test "should .validates_age_over work" do
    user = FactoryGirl.build(:user)
    user.update_attribute(:born_at, DateTime.now-10.years)
    @collaboration.user = user
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:user].include? "No puedes colaborar si eres menor de edad.")
  end

  test "should .validates_ccc work" do
    @collaboration.payment_type = 2
    @collaboration.ccc_entity = '9000'
    @collaboration.ccc_office = '0001'
    @collaboration.ccc_dc = '21'
    @collaboration.ccc_account = '0123456789'
    assert @collaboration.valid?

    @collaboration.ccc_dc = '11'
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:ccc_dc].include? "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
  end

  test "should .validates_iban work" do
    @collaboration.payment_type = 3
    @collaboration.iban_account = "ES0690000001210123456789"
    @collaboration.iban_bic = "ESPBESMMXXX"
    assert @collaboration.valid?

    @collaboration.iban_account = "ES1111111111111111111111"
    @collaboration.iban_bic = "ESPBESMMXXX"
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:iban_account].include? "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
  end

  test "should .is_credit_card? work" do
    @collaboration.update_attribute(:payment_type, 1)
    assert @collaboration.is_credit_card?
    @collaboration.update_attribute(:payment_type, 2)
    assert_not @collaboration.is_credit_card?
    @collaboration.update_attribute(:payment_type, 3)
    assert_not @collaboration.is_credit_card?
  end

  test "should .is_bank_national? work" do
    @collaboration.update_attribute(:payment_type, 1)
    assert_not @collaboration.is_bank_national?
    @collaboration.update_attribute(:payment_type, 2)
    assert @collaboration.is_bank_national?
    @collaboration.update_attribute(:payment_type, 3)
    assert_not @collaboration.is_bank_national?
  end

  test "should .is_bank_international? work" do
    @collaboration.update_attribute(:payment_type, 1)
    assert_not @collaboration.is_bank_international?
    @collaboration.update_attribute(:payment_type, 2)
    assert_not @collaboration.is_bank_international?
    @collaboration.update_attribute(:payment_type, 3)
    assert @collaboration.is_bank_international?
  end

  test "should .payment_type_name work" do
    @collaboration.update_attribute(:payment_type, 1)
    assert_equal( "Suscripción con Tarjeta de Crédito/Débito", @collaboration.payment_type_name ) 
    @collaboration.update_attribute(:payment_type, 2)
    assert_equal( "Domiciliación en cuenta bancaria (CCC)", @collaboration.payment_type_name ) 
    @collaboration.update_attribute(:payment_type, 3)
    assert_equal( "Domiciliación en cuenta extranjera (IBAN)", @collaboration.payment_type_name ) 
  end

  test "should .frequency_name work" do
    @collaboration.update_attribute(:frequency, 1)
    assert_equal( "Mensual", @collaboration.frequency_name ) 
    @collaboration.update_attribute(:frequency, 3)
    assert_equal( "Trimestral", @collaboration.frequency_name ) 
    @collaboration.update_attribute(:frequency, 12)
    assert_equal( "Anual", @collaboration.frequency_name ) 
  end

  test "should .status_name work" do
    @collaboration.update_attribute(:status, 0)
    assert_equal( "Sin pago", @collaboration.status_name ) 
    @collaboration.update_attribute(:status, 1)
    assert_equal( "Error", @collaboration.status_name ) 
    @collaboration.update_attribute(:status, 2)
    assert_equal( "Sin confirmar", @collaboration.status_name ) 
    @collaboration.update_attribute(:status, 3)
    assert_equal( "OK", @collaboration.status_name ) 
    @collaboration.update_attribute(:status, 4)
    assert_equal( "Alerta", @collaboration.status_name ) 
  end

  test "should .ccc_full work" do 
    assert_equal "90000001210123456789", @collaboration.ccc_full
    @collaboration.ccc_dc = 5
    assert_equal "90000001050123456789", @collaboration.ccc_full
  end

  test "should .pretty_ccc_full work" do 
    assert_equal "9000 0001 21 0123456789", @collaboration.pretty_ccc_full
    @collaboration.ccc_dc = 5
    assert_equal "9000 0001 05 0123456789", @collaboration.pretty_ccc_full
  end

  test "should .calculate_bic work" do 
    ccc = FactoryGirl.create(:collaboration, :ccc) 
    assert_equal "ESPBESMMXXX", ccc.calculate_bic
    iban = FactoryGirl.create(:collaboration, :iban) 
    assert_equal "ESPBESMMXXX", iban.calculate_bic
  end

  test "should .is_recurrent? work" do
    assert @collaboration.is_recurrent?
  end

  test "should .is_payable? work" do
    @collaboration.update_attribute(:status, 0) 
    assert_not @collaboration.is_payable?
    @collaboration.update_attribute(:status, 1) 
    assert_not @collaboration.is_payable?
    @collaboration.update_attribute(:status, 2) 
    assert @collaboration.is_payable?
    @collaboration.update_attribute(:status, 3) 
    assert @collaboration.is_payable?
    @collaboration.update_attribute(:status, 4) 
    assert_not @collaboration.is_payable?
    @collaboration.update_attribute(:deleted_at, DateTime.now) 
    assert_not @collaboration.is_payable?
    @collaboration.update_attribute(:status, 2) 
    @collaboration.update_attribute(:deleted_at, nil) 
    assert @collaboration.is_payable?
    @collaboration.update_attribute(:user, nil) 
    assert_not @collaboration.is_payable?
  end

  test "should .is_active? work" do
    @collaboration.update_attribute(:status, 0)
    assert_not @collaboration.is_active?
    @collaboration.update_attribute(:status, 1)
    assert_not @collaboration.is_active?
    @collaboration.update_attribute(:status, 2)
    assert @collaboration.is_active?
    @collaboration.update_attribute(:status, 3)
    assert @collaboration.is_active?
    @collaboration.update_attribute(:status, 4)
    assert @collaboration.is_active?
    @collaboration.update_attribute(:deleted_at, DateTime.now)
    @collaboration.update_attribute(:status, 4)
    assert_not @collaboration.is_active?
  end

  test "should .has_payment? work" do
    @collaboration.update_attribute(:status, 0)
    assert_not @collaboration.has_payment?
    @collaboration.update_attribute(:status, 1)
    assert @collaboration.has_payment?
    @collaboration.update_attribute(:status, 2)
    assert @collaboration.has_payment?
    @collaboration.update_attribute(:status, 3)
    assert @collaboration.has_payment?
    @collaboration.update_attribute(:status, 4)
    assert @collaboration.has_payment?
  end

  test "should .check_spanish_bic work" do 
    ccc = FactoryGirl.create(:collaboration, :ccc) 
    assert_equal "ESPBESMMXXX", ccc.calculate_bic
  end

  test "should .admin_permalink work" do
    assert_equal "/admin/collaborations/#{@collaboration.id}", @collaboration.admin_permalink
  end

  test "should .first_order work" do
    order1 = @collaboration.create_order DateTime.now-6.months
    order2 = @collaboration.create_order DateTime.now-5.months
    order3 = @collaboration.create_order DateTime.now-4.months
    order4 = @collaboration.create_order DateTime.now-3.months
    order5 = @collaboration.create_order DateTime.now+3.months
    order1.save
    order2.save
    order3.save
    order4.save
    order5.save
    assert_equal order1, @collaboration.first_order
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
    credit_card = FactoryGirl.create(:collaboration, :credit_card)
    credit_card.update_attribute(:redsys_identifier, "XXXXXX")
    assert_equal credit_card.payment_identifier, "XXXXXX"
    iban = FactoryGirl.create(:collaboration, :iban)
    iban.update_attribute(:payment_type, 3)  
    assert_equal iban.payment_identifier, "ES0690000001210123456789/ESPBESMMXXX"
    ccc = FactoryGirl.create(:collaboration, :ccc)
    assert_equal ccc.payment_identifier, "ES0690000001210123456789/ESPBESMMXXX"
  end

  test "should .payment_processed work" do
    order = @collaboration.create_order Date.today
    order.save
    assert_equal 0, @collaboration.status

    @collaboration.payment_processed order
    assert_equal 0, @collaboration.status

    order.update_attribute(:status, 2) 
    order.update_attribute(:payed_at, Date.today) 
    @collaboration.payment_processed order
    assert_equal 3, @collaboration.status

    order.update_attribute(:status, 4) 
    @collaboration.payment_processed order
    assert_equal 1, @collaboration.status

    credit_card = FactoryGirl.create(:collaboration, :credit_card) 
    credit_card_order = credit_card.create_order Date.today
    credit_card_order.save 
    credit_card.payment_processed credit_card_order
    assert_equal credit_card_order.payment_identifier, credit_card.redsys_identifier
    assert_equal credit_card_order.redsys_expiration, credit_card.redsys_expiration
  end

  test "should .has_warnings? work" do
    @collaboration.update_attribute(:status, 1)
    assert_not @collaboration.has_warnings?
    @collaboration.update_attribute(:status, 2)
    assert_not @collaboration.has_warnings?
    @collaboration.update_attribute(:status, 3)
    assert_not @collaboration.has_warnings?
    @collaboration.update_attribute(:status, 4)
    assert @collaboration.has_warnings?
  end

  test "should .has_errors? work" do
    @collaboration.update_attribute(:status, 1)
    assert @collaboration.has_errors?
    @collaboration.update_attribute(:status, 2)
    assert_not @collaboration.has_errors?
    @collaboration.update_attribute(:status, 3)
    assert_not @collaboration.has_errors?
    @collaboration.update_attribute(:status, 4)
    assert_not @collaboration.has_errors?
  end

  test "should .set_warning work" do
    @collaboration.set_warning
    assert_equal @collaboration.status, 4
  end

  test "should .must_have_order? work" do
    assert_not @collaboration.must_have_order? Date.today-1.year
    assert_not @collaboration.must_have_order? Date.today-1.month
    assert @collaboration.must_have_order? Date.today+1.month
    assert @collaboration.must_have_order? Date.today+1.year

    date = @collaboration.created_at
    date = date.change(day: Order.payment_day)
    
    @collaboration.created_at = date - 1.day
    assert @collaboration.must_have_order? Date.today

    @collaboration.created_at = date + 1.day
    assert_not @collaboration.must_have_order? Date.today

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
    assert_equal @collaboration.ok_url, "http://localhost/colabora/OK"
  end

  test "should .ko_url work" do
    assert_equal @collaboration.ko_url, "http://localhost/colabora/KO"
  end

  test "should .charge! work" do
    collaboration = FactoryGirl.create(:collaboration, :credit_card) 
    collaboration.update_attribute(:status, 2)
    order = collaboration.create_order Date.today
    order.save
    assert_equal "Nueva", order.status_name
    assert_equal nil, order.payment_response 

    stub_request(:post, order.redsys_post_url).to_return(:status => 200, :body => "<!-- +(RSisReciboOK)+ -->", :headers => {})
    collaboration.charge!
    assert_requested :post, order.redsys_post_url
    order.reload
    assert_equal "OK", order.status_name
    assert_equal "[\"RSisReciboOK\"]", order.payment_response 
  end

  test "should .get_bank_data work" do
    order = @collaboration.create_order Date.today
    order.save
    response = ["1503000001", "PEREZ PEPITO", @collaboration.user.document_vatid, @collaboration.user.email, "C/ INVENTADA, 123", "MADRID", "28021", "ES", nil, "90000001210123456789", nil, 10, "RCUR", "http://localhost/colabora", 1, order.created_at.strftime("%d-%m-%Y"), "Colaboración marzo 2015", order.payable_at.strftime("%d-%m-%Y"), "Mensual", "PEREZ PEPITO"]
    assert_equal( response, @collaboration.get_bank_data(Date.today) )
  end

  test "should Collaboration::NonUser work" do 
    non_user = Collaboration::NonUser.new({
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX", 
      email: "foo@example.com",
      invalid_field: "do not save"
    })
    assert_equal non_user.legacy_id, 2
    assert_equal non_user.full_name, "Pepito Perez"
    assert_equal non_user.document_vatid, "XXXXXX"
    assert_equal non_user.email, "foo@example.com"
    #assert_equal non_user.invalid_field, nil
    assert_equal non_user.to_s, "Pepito Perez (XXXXXX - foo@example.com)"
  end

  test "should .parse_non_user work" do
    @collaboration. user = nil
    @collaboration.non_user_data = "--- !ruby/object:Collaboration::NonUser
legacy_id: 1
full_name: XXXXXXXXXXXXXXXXX
document_vatid: XXXXXXXXX
email: pepito@example.com
address: Av. Siempreviva 123
town_name: Madrid
postal_code: '28024'
country: ES
province: 'Madrid'
phone: '666666'"
    parse = @collaboration.parse_non_user
    assert_equal "XXXXXXXXXXXXXXXXX", parse.full_name
    assert_equal "XXXXXXXXX", parse.document_vatid
    assert_equal "pepito@example.com", parse.email
    assert_equal "Av. Siempreviva 123", parse.address
    assert_equal "Madrid", parse.town_name
    assert_equal "28024", parse.postal_code
    assert_equal "ES", parse.country
    assert_equal "Madrid", parse.province
    assert_equal "666666", parse.phone
  end

  test "should .format_non_user work" do
    info = {
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX", 
      email: "foo@example.com",
      invalid_field: "do not save"
    }
    @collaboration.user = nil
    @collaboration.set_non_user info
    @collaboration.save
    assert @collaboration.valid?
    assert_equal "XXXXXX", @collaboration.non_user_document_vatid 
    assert_equal "foo@example.com", @collaboration.non_user_email
  end

  test "should .set_non_user work" do
    info = {
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX", 
      email: "foo@example.com",
      invalid_field: "do not save"
    }
    @collaboration.user = nil
    @collaboration.set_non_user info
    assert @collaboration.valid?
    assert_equal "XXXXXX", @collaboration.non_user_document_vatid
    assert_equal "foo@example.com", @collaboration.non_user_email 
  end

  test "should .get_user work" do
    info = {
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX", 
      email: "foo@example.com",
      invalid_field: "do not save"
    }
    assert_equal "User", @collaboration.get_user.class.name
    @collaboration.user = nil
    @collaboration.set_non_user info
    assert_equal "Collaboration::NonUser", @collaboration.get_user.class.name
  end

  test "should .get_non_user work" do
    info = {
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX11", 
      email: "pepito@example.com",
      address: "Av. Siempreviva 123",
      town_name: "Madrid",
      postal_code: "28024",
      country: "ES",
      province: "Madrid",
      phone: "666666",
      invalid_field: "do not save"
    }
    @collaboration.user = nil
    @collaboration.set_non_user info
    user = @collaboration.get_non_user
    assert_equal user.legacy_id, 2
    assert_equal user.full_name, 'Pepito Perez'
    assert_equal user.document_vatid, 'XXXXXX11'
    assert_equal user.email, 'pepito@example.com'
    assert_equal user.address, 'Av. Siempreviva 123'
    assert_equal user.town_name, 'Madrid'
    assert_equal user.postal_code, '28024'
    assert_equal user.country, 'ES'
    assert_equal user.province, 'Madrid'
    assert_equal user.phone, '666666'
  end

  test "should .validates_has_user work" do
    # valid with a normal user
    assert @collaboration.valid?

    # invalid without user
    @collaboration.user = nil 
    assert_not @collaboration.valid?
    assert @collaboration.errors[:user].include? "La colaboración debe tener un usuario asociado."

    # valid with non_user model
    info = {
      legacy_id: 2,
      full_name: "Pepito Perez",
      document_vatid: "XXXXXX", 
      email: "foo@example.com",
      invalid_field: "do not save"
    }
    @collaboration.user = nil
    @collaboration.set_non_user info
    assert @collaboration.valid?
  end

  test "should .bank_filename work" do
    date = Date.today
    filename = "podemos.orders.#{date.year.to_s}.#{date.month.to_s}"
    full_filename = "#{Rails.root}/db/podemos/#{filename}.csv"
    assert_equal full_filename, Collaboration.bank_filename(Date.today)
    assert_equal filename, Collaboration.bank_filename(Date.today, false)
  end

  test "should .bank_file_lock work" do 
    assert_not File.exists? Collaboration::BANK_FILE_LOCK
    Collaboration.bank_file_lock true
    assert File.exists? Collaboration::BANK_FILE_LOCK
    Collaboration.bank_file_lock false
    assert_not File.exists? Collaboration::BANK_FILE_LOCK
  end

  test "should Collaboration.has_bank_file? work" do 
    assert Collaboration.has_bank_file? Date.today
    #@collaboration.BANK_FILE_LOCK
  end

  test "should update_paid_unconfirmed_bank_collaborations orders work" do 
    date = Date.today
    @collaboration.create_order(date - 1.month ).save
    @collaboration.create_order(date - 2.month ).save
    @collaboration.create_order(date - 3.month ).save
    @collaboration.create_order(date - 4.month ).save

    Order.where(collaboration: @collaboration).each {|o| o.update_attribute(:status, 0) }
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    @collaboration.reload
    assert_equal 0, @collaboration.status

    Order.where(collaboration: @collaboration).each {|o| o.update_attribute(:status, 1) }
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    @collaboration.reload
    assert_equal 0, @collaboration.status

    Order.where(collaboration: @collaboration).each {|o| o.update_attribute(:status, 2) }
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    @collaboration.reload
    assert_equal 3, @collaboration.status

    Order.where(collaboration: @collaboration).each {|o| o.update_attribute(:status, 3) }
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    @collaboration.reload
    assert_equal 3, @collaboration.status

    Order.where(collaboration: @collaboration).each {|o| o.update_attribute(:status, 4) }
    Collaboration.update_paid_unconfirmed_bank_collaborations(Order.banks.by_date(date, date).charging)
    @collaboration.reload
    assert_equal 3, @collaboration.status
  end

  ##############################################

  test "should not save collaboration if userr is not over legal age (18 years old)" do
    user = FactoryGirl.build(:user)
    user.update_attribute(:born_at, DateTime.now-10.years)
    @collaboration.user = user
    assert_not @collaboration.valid?
    assert(@collaboration.errors[:user].include? "No puedes colaborar si eres menor de edad.")
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

  test "should .create_order before collection created returns false" do
    coll = FactoryGirl.create(:collaboration, :june2014)
    assert_not coll.create_order(DateTime.new(2014,3,1)).save, "create_order should not consider dates previous to collaboration creation"
  end

  test "should .create_order after collection created but the same month returns false" do
    coll = FactoryGirl.create(:collaboration, :ccc, created_at: DateTime.new(2014,6,10))
    order = coll.create_order(DateTime.new(2014,6,5))
    assert_not order.save, "create_order should not consider collaboration created after date"
    order = coll.create_order(DateTime.new(2014,6,15))
    assert order.save, "create_order should consider collaboration created before date"
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
    @collaboration.update_attribute(:created_at, Date.today)
    order = @collaboration.get_orders
    assert_equal "order", order
  end

  test "should .get_orders work after and before payment day." do
    @collaboration.update_attribute(:created_at, Date.today)
    orders = @collaboration.get_orders(Date.today-2.month, Date.today-1.month)
    assert_equal 0, orders.count
    orders = @collaboration.get_orders(Date.today, Date.today+1.month)
    assert_equal 1, orders.count
  end

  test "should .get_orders work with paid and unpaid collaborations." do
    assert false
  end
end
