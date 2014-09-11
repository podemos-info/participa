require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should validate presence:true" do
    u = User.new
    u.save
    assert(u.errors[:email].include? "Tu correo electrónico no puede estar en blanco")
    assert(u.errors[:password].include? "Tu contraseña no puede estar en blanco")
    assert(u.errors[:first_name].include? "Tu nombre no puede estar en blanco")
    assert(u.errors[:last_name].include? "Tu apellido no puede estar en blanco")
    assert(u.errors[:document_type].include? "Tu tipo de documento no puede estar en blanco")
    assert(u.errors[:document_vatid].include? "Tu documento no puede estar en blanco")
    assert(u.errors[:born_at].include? "Tu fecha de nacimiento no puede estar en blanco")
  end

  test "should email and document_vatid be unique" do
    skip("TODO")
  end

  test "should accept terms of service" do
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
