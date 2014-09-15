require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do 
    @user = FactoryGirl.create(:user)
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
    assert(u.errors[:born_at].include? "Tu fecha de nacimiento no puede estar en blanco")
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

  test "should have valid born_at" do
    u = User.new(born_at: Date.civil(1908, 2, 1))
    u.valid?
    assert(u.errors[:born_at].include? "debes haber nacido después de 1920")
    u = User.new(born_at: Date.civil(2017, 2, 1))
    u.valid?
    assert(u.errors[:born_at].include? "debes haber nacido después de 1920")
    u = User.new(born_at: Date.civil(1988, 2, 1))
    u.valid?
    assert(u.errors[:born_at], [])
  end

  test "should document_type inclusion work" do
    skip("TODO")
  end

  test "should .full_name work" do
    u = User.new(first_name: "Juan", last_name: "Perez")
    assert_equal(u.full_name, "Juan Perez")
  end

  test "should .is_admin? method work" do
    skip("TODO")
  end

end
