require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do 
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
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
    user2 = FactoryGirl.build(:user, email: @user.email)
    user2.valid?
    assert(user2.errors[:email].include? "Ya estas registrado con tu correo electrónico. Prueba a iniciar sesión o a pedir que te recordemos la contraseña.")

    user2 = FactoryGirl.build(:user, document_vatid: "17623610K")
    assert(user2.errors[:email] == [])
  end

  test "should document_vatid be unique" do
    user1 = FactoryGirl.create(:user, email: "foo222@example.com", document_vatid: "26502303R")
    user2 = FactoryGirl.build(:user, email: "foo222@example.com", document_vatid: "26502303R")
    user2.valid?
    assert(user2.errors[:email].include? "Ya estas registrado con tu correo electrónico. Prueba a iniciar sesión o a pedir que te recordemos la contraseña.")
    user2 = FactoryGirl.build(:user, email: "foo888@example.com")
    assert(user2.errors[:email] == [])
  end

  test "should accept terms of service" do
    skip("TODO")
  end

  #test "should have valid born_at" do
  #  u = User.new(born_at: Date.civil(1908, 2, 1))
  #  u.valid?
  #  assert(u.errors[:born_at].include? "debes haber nacido después de 1920")
  #  u = User.new(born_at: Date.civil(2017, 2, 1))
  #  u.valid?
  #  assert(u.errors[:born_at].include? "debes haber nacido después de 1920")
  #  u = User.new(born_at: Date.civil(1988, 2, 1))
  #  u.valid?
  #  assert(u.errors[:born_at], [])
  #end

  test "should document_type inclusion work" do
    skip("TODO")
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

  test "should .is_valid_phone? work" do
    u = User.new
    assert_not(u.is_valid_phone?)
    u.sms_confirmed_at = DateTime.now
    assert(u.is_valid_phone?)
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
    skip("TODO")
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
    FactoryGirl.create(:no_newsletter_user)
    assert_equal 2, User.wants_newsletter.count
    FactoryGirl.create(:newsletter_user)
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
    user1 = FactoryGirl.build(:user, email: @user.email, document_vatid: @user.document_vatid, phone: @user.phone)
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

    user = FactoryGirl.build(:user, email: "testwithnewmail@example.com", document_vatid: "222222X", phone: "00344444444")
    assert user.valid?
  end

end
