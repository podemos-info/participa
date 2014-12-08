require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do 
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:user, :admin)
  end

  test "should validate presence:true" do
    u = User.new
    u.valid?
    assert(u.errors[:email].include? "Tu correo electrónico no puede estar en blanco")
    assert(u.errors[:password].include? "Tu contraseña no puede estar en blanco")
    assert(u.errors[:first_name].include? "Tu nombre no puede estar en blanco")
    assert(u.errors[:last_name].include? "Tu apellido no puede estar en blanco")
    assert(u.errors[:document_type].include? "Tu tipo de documento no puede estar en blanco")
    assert(u.errors[:document_vatid].include? "Tu documento no puede estar en blanco")
    #assert(u.errors[:born_at].include? "Tu fecha de nacimiento no puede estar en blanco")
    assert(u.errors[:address].include? "Tu dirección no puede estar en blanco")
    assert(u.errors[:town].include? "Tu municipio o localidad no puede estar en blanco")
    assert(u.errors[:postal_code].include? "Tu código postal no puede estar en blanco")
    assert(u.errors[:province].include? "Tu provincia no puede estar en blanco")
    assert(u.errors[:country].include? "Tu país no puede estar en blanco")
  end

  test "should document_vatid validates with DNI/NIE" do 
    u = User.new(document_type: 1, document_vatid: "222222E")
    u.valid?
    assert(u.errors[:document_vatid].include? "El DNI no es válido")

    u = User.new(document_type: 2, document_vatid: "222222E")
    u.valid?
    assert(u.errors[:document_vatid].include? "El NIE no es válido")

    u = User.new(document_type: 1, document_vatid: "99115002K")
    u.valid?
    assert(u.errors[:document_vatid] == [])

    u = User.new(document_type: 2, document_vatid: "Z4901305X")
    u.valid?
    assert(u.errors[:document_vatid] == [])
  end

  test "should email be unique" do
    error_message = I18n.t "activerecord.errors.models.user.attributes.email.taken"
    user2 = FactoryGirl.build(:user, email: @user.email)
    user2.valid?
    assert(user2.errors[:email].include? error_message)

    user2 = FactoryGirl.build(:user, email: "newuniqueemail@example.com")
    assert(user2.errors[:email] == [])
  end

  test "should document_vatid be unique" do
    error_message = I18n.t "activerecord.errors.models.user.attributes.document_vatid.taken"

    # try to save with the same document
    user1 = FactoryGirl.create(:user, document_vatid: "26502303R")
    user2 = FactoryGirl.build(:user, document_vatid: "26502303R")
    user2.valid?
    assert(user2.errors[:document_vatid].include? error_message)

    # downcase ( minusculas )
    user3 = FactoryGirl.build(:user, document_vatid: "26502303r")
    user3.valid?
    assert(user3.errors[:document_vatid].include? error_message)

    # spaces
    user4 = FactoryGirl.build(:user, document_vatid: " 26502303r ")
    user4.valid?
    assert(user4.errors[:document_vatid].include? error_message)

    user5 = FactoryGirl.build(:user, document_vatid: "1111111H")
    assert(user5.valid?)
  end

  test "should accept terms of service and over_18" do
    u = User.new(terms_of_service: false, over_18: false)
    u.valid?
    u.errors[:terms_of_service].include? ["debe ser aceptado"]
    u.errors[:over_18].include? ["debe ser aceptado"]
  end

  test "should have valid born_at" do
    u = User.new(born_at: Date.civil(2017, 2, 1))
    u.valid?
    assert(u.errors[:born_at].include? "debes ser mayor de 18 años")
    u = User.new(born_at: Date.civil(1888, 2, 1))
    u.valid?
    assert(u.errors[:born_at].include? "debes ser mayor de 18 años")
    u = User.new(born_at: Date.civil(1988, 2, 1))
    u.valid?
    assert(u.errors[:born_at], [])
  end

  test "should document_type inclusion work" do
    u = User.new(document_type: 4)
    u.valid? 
    assert(u.errors[:document_type].include?  "Tipo de documento no válido")

    u = User.new(document_type: 0)
    u.valid? 
    assert(u.errors[:document_type].include?  "Tipo de documento no válido")

    u = User.new(document_type: 1)
    u.valid? 
    assert(u.errors[:document_type], [])

    u = User.new(document_type: 2)
    u.valid? 
    assert(u.errors[:document_type], [])

    u = User.new(document_type: 3)
    u.valid? 
    assert(u.errors[:document_type], [])
  end

  test "should .full_name work" do
    u = User.new(first_name: "Juan", last_name: "Perez")
    assert_equal(u.full_name, "Juan Perez")
  end

  test "should .is_admin? method work" do
    u = User.new
    assert_not u.is_admin?
    assert_not @user.is_admin?
    assert @admin.is_admin?
    new_admin = FactoryGirl.create(:user, document_type: 3, document_vatid: '2222222')
    assert_not new_admin.is_admin?
    new_admin.update_attribute(:admin, true)
    assert new_admin.is_admin?
  end

  test "should phone be numeric or nil work" do
    @user.phone = nil
    assert @user.valid?
    @user.phone = "aaaa"
    assert_not @user.valid?
    assert @user.errors[:phone].include?("Revisa el formato de tu teléfono")
  end

  test "should unconfirmed_phone be numeric or nil work" do
    @user.unconfirmed_phone = nil
    assert @user.valid?
    @user.unconfirmed_phone = "aaaa"
    assert_not @user.valid?
    assert @user.errors[:unconfirmed_phone].include?("Revisa el formato de tu teléfono")
  end

  test "should validates_phone_format work" do
    @user.phone = "12345"
    assert_not @user.valid?
    assert @user.errors[:phone].include?("Revisa el formato de tu teléfono")
  end

  test "should validates_unconfirmed_phone_format work" do 
    @user.unconfirmed_phone = "12345"
    assert_not @user.valid?
    assert @user.errors[:unconfirmed_phone].include?("Revisa el formato de tu teléfono")
  end

  test "should validates_unconfirmed_phone_format only accept numbers starting with 6 or 7" do 
    @user.unconfirmed_phone = "0034661234567"
    assert @user.valid?
    @user.unconfirmed_phone = "0034771234567"
    assert @user.valid?
    @user.unconfirmed_phone = "0034881234567"
    assert_not @user.valid?
    assert @user.errors[:unconfirmed_phone].include?("Debes poner un teléfono móvil válido de España empezando por 6 o 7.")
  end

  test "should validates_unconfirmed_phone_phone_uniqueness work" do
    phone = "0034612345678"
    @user.update_attribute(:phone, phone)
    user = FactoryGirl.create(:user)
    user.unconfirmed_phone = phone
    assert_not user.valid?
    assert user.errors[:phone].include?("Ya hay alguien con ese número de teléfono")
  end

  #test "should .is_valid_phone? work" do
  #  u = User.new
  #  assert_not(u.is_valid_phone?)
  #  u.sms_confirmed_at = DateTime.now
  #  assert(u.is_valid_phone?)
  #end

  test "should .can_change_phone? work" do 
    @user.update_attribute(:sms_confirmed_at, DateTime.now-1.month )
    assert_not @user.can_change_phone?
    @user.update_attribute(:sms_confirmed_at, DateTime.now-7.month )
    assert @user.can_change_phone?
    @user.update_attribute(:sms_confirmed_at, nil)
    assert @user.can_change_phone?
  end

  test "should .phone_normalize work" do 
    assert_equal( "0034661234567", @user.phone_normalize("661234567", "ES") ) 
    assert_equal( "0034661234567", @user.phone_normalize("0034661234567", "ES") )
    assert_equal( "0034661234567", @user.phone_normalize("+34661234567", "ES") )
    assert_equal( "0034661234567", @user.phone_normalize("+34 661 23 45 67", "ES") )
    assert_equal( "0034661234567", @user.phone_normalize("0034661234567") )
    assert_equal( "0034661234567", @user.phone_normalize("+34661234567") )
    assert_equal( "0034661234567", @user.phone_normalize("+34 661 23 45 67") )
    assert_equal( "0054661234567", @user.phone_normalize("661234567", "AR") )
  end

  test "should .phone_prefix work" do 
    assert_equal "34", @user.phone_prefix
    @user.update_attribute(:country, "AR")
    assert_equal "54", @user.phone_prefix
  end

  test "should .phone_country_name work" do 
    assert_equal "España", @user.phone_country_name
    @user.update_attribute(:phone, "005446311234")
    assert_equal "Argentina", @user.phone_country_name
  end

  test "should .phone_no_prefix work" do 
    @user.update_attribute(:phone, "00346611111222")
    assert_equal "6611111222", @user.phone_no_prefix
    @user.update_attribute(:phone, "005446311234")
    assert_equal "46311234", @user.phone_no_prefix
  end

  test "should .generate_sms_token work" do
    u = User.new
    token = u.generate_sms_token
    assert(!!(token.match(/^[[:alnum:]]+$/)))
  end

  test "should .set_sms_token! work" do
    u = User.new
    assert(u.sms_confirmation_token.nil?)
    u.set_sms_token!
    assert(u.sms_confirmation_token?)
  end

  test "should .send_sms_token! work" do
    @user.send_sms_token!
    # comprobamos que el SMS se haya enviado en los últimos 10 segundos
    assert( @user.confirmation_sms_sent_at - DateTime.now  > -10 )
  end

  test "should .check_sms_token work" do
    u = User.new
    u.set_sms_token!
    token = u.sms_confirmation_token
    assert(u.check_sms_token(token))
    assert_not(u.check_sms_token("LALALAAL"))
  end

  test "should .document_type_name work" do 
    @user.update_attribute(:document_type, 1)
    assert_equal "DNI", @user.document_type_name
    @user.update_attribute(:document_type, 2)
    assert_equal "NIE", @user.document_type_name
    @user.update_attribute(:document_type, 3)
    assert_equal "Pasaporte", @user.document_type_name
  end

  test "should .country_name work" do 
    @user.update_attribute(:country, "ES")
    assert_equal "España", @user.country_name
    @user.update_attribute(:country, "AR")
    assert_equal "Argentina", @user.country_name
    @user.update_attribute(:country, "Testing")
    assert_equal "Testing", @user.country_name
  end

  test "should .province_name work" do 
    @user.update_attribute(:country, "ES")
    @user.update_attribute(:province, "C")
    assert_equal "A Coruña", @user.province_name
    @user.update_attribute(:country, "AR")
    @user.update_attribute(:province, "C")
    assert_equal "Ciudad Autónoma de Buenos Aires", @user.province_name
    @user.update_attribute(:province, "Testing")
    assert_equal "Testing", @user.province_name
  end

  test "should scope .wants_newsletter work" do 
    assert_equal 2, User.wants_newsletter.count
    FactoryGirl.create(:user, :no_newsletter_user)
    assert_equal 2, User.wants_newsletter.count
    FactoryGirl.create(:user, :newsletter_user)
    assert_equal 3, User.wants_newsletter.count
  end

  test "should act_as_paranoid" do 
    @user.destroy
    assert_not User.exists?(@user.id)
    assert User.with_deleted.exists?(@user.id)
    @user.restore
    assert User.exists?(@user.id)
  end

  test "should scope uniqueness with paranoia" do 
    @user.destroy
    # allow save after the @user is destroyed but is with deleted_at
    user1 = FactoryGirl.build(:user, email: @user.email, email_confirmation: @user.email, document_vatid: @user.document_vatid, phone: @user.phone)
    user1.valid?
    assert user1.valid?
    user1.save

    # don't allow save after the @user is created again (uniqueness is working)
    user2 = FactoryGirl.build(:user, email: @user.email, document_vatid: @user.document_vatid, phone: @user.phone)
    assert_not user2.valid?
  end

  test "should uniqueness work" do 
    user = FactoryGirl.build(:user, email: @user.email, document_vatid: @user.document_vatid, phone: @user.phone)
    assert_not user.valid?
    assert_not_nil user.errors.include? :email
    assert_not_nil user.errors.include? :document_vatid
    assert_not_nil user.errors.include? :phone

    user = FactoryGirl.build(:user, email: "testwithnewmail@example.com", document_vatid: "222222X", phone: "0034661234567")
    assert user.valid?
  end

  test "should uniqueness not be case sensitive" do 
    user = FactoryGirl.build(:user, document_vatid: @user.document_vatid.downcase)
    assert_not user.valid?
    user = FactoryGirl.build(:user, document_vatid: @user.document_vatid.upcase)
    assert_not user.valid?
  end

  test "should email confirmation work" do 
    user = FactoryGirl.build(:user, email_confirmation: nil)
    user.valid?
    assert_not user.valid?
    assert user.errors[:email_confirmation].include? "no puede estar en blanco"

    user = FactoryGirl.build(:user, email_confirmation: "notthesameemail@gmail.com")
    user.valid?
    assert_not user.valid?
    assert user.errors[:email_confirmation].include? "no coincide con la confirmación"
  end

  test "should be over 18 on born_at" do 
    user = FactoryGirl.build(:user, born_at: Date.civil(2000, 1, 1))
    user.valid?
    assert_not user.valid?
    assert user.errors[:born_at].include? "debes ser mayor de 18 años"
  end 

  #test "should all scopes work" do 
  #  skip("TODO")
  #end
  #
  #scope :all_with_deleted, -> { where "deleted_at IS null AND deleted_at IS NOT null"  }
  #scope :users_with_deleted, -> { where "deleted_at IS NOT null"  }
  #scope :wants_newsletter, -> {where(wants_newsletter: true)}
  #scope :created, -> { where "deleted_at is null"  }
  #scope :deleted, -> { where "deleted_at is not null" }
  #scope :unconfirmed_mail, -> { where "confirmed_at is null" }
  #scope :unconfirmed_phone, -> { where "sms_confirmed_at is null" }
  #scope :legacy_password, -> { where(has_legacy_password: true) }

end
