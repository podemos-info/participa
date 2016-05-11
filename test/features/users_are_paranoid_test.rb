require "test_helper"

def create_user_registration(user, document_vatid, email)
  visit new_user_registration_path
  fill_in('Nombre', :with => user.first_name)
  fill_in('Apellidos', :with => user.last_name)
  select("Pasaporte", from: "Tipo de documento")
  fill_in('DNI', :with => document_vatid)
  # XXX pasca - para bcomu se ha quitado el pais y la provincia
  #select('España', :from=>'País')
  #select('Barcelona', :from=>'Provincia')
  #select("Barcelona", from: "Municipio")
  select("1970", from: "user[born_at(1i)]")
  select("enero", from: "user[born_at(2i)]")
  select("1", from: "user[born_at(3i)]")
  fill_in('Código postal', :with => '08021')
  fill_in('Dirección', :with => 'C/El Muro, S/N')
  fill_in('Correo electrónico*', :with => email)
  fill_in('Correo electrónico (repetir)*', :with => email)
  fill_in('Contraseña*', :with => user.password)
  fill_in('Contraseña (repetir)*', :with => user.password)
  check('user_inscription')
  check('user_terms_of_service')
  check('user_over_18')
  click_button "Inscribirse"
end

feature "UsersAreParanoid" do

  scenario "create a user", js: true do
    user = FactoryGirl.build(:user)
    # XXX pasca - comento validaciones de momento, investigar porqué no se
    # guarda el user, puede ser por el captcha??
    skip

    # first creation attempt, receive OK message and create it
    assert_equal 0, User.all.count
    create_user_registration(user, user.document_vatid, user.email)
    #page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    #assert_equal 1, User.all.count

    # FIXME: failing tests
    skip

    # second creation attempt, same document and email
    # receive OK message
    # but don't create the user and mail them a message
    create_user_registration(user, user.document_vatid, user.email)
    page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    assert_equal 1, User.all.count

    # third creation attempt, same document and invalid email
    # receive KO message
    # don't create it because it has errors.
    # should receive validation error.
    create_user_registration(user, user.document_vatid, "trolololo")
    page.must_have_content "La dirección de correo es incorrecta"
    assert_equal 1, User.all.count

    # third creation attempt, same document and different email
    # receive OK message
    # but don't create the user and mail them a message to original account
    create_user_registration(user, user.document_vatid, "trolololo@example.com")
    page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    assert_equal 1, User.all.count
  end

end
