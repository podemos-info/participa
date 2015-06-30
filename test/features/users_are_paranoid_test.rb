require "test_helper"

def create_user_registration(user, document_vatid, email)
  visit new_user_registration_path
  fill_in('Nombre', :with => user.first_name)
  fill_in('Apellidos', :with => user.last_name)
  select("Pasaporte", from: "Tipo de documento")
  fill_in('Nº de documento', :with => document_vatid)
  select('España', :from=>'País')
  select('Barcelona', :from=>'Provincia')
  select("Barcelona", from: "Municipio")
  select("1970", from: "user[born_at(1i)]")
  select("enero", from: "user[born_at(2i)]")
  select("1", from: "user[born_at(3i)]")
  fill_in('Código postal', :with => '08021')
  fill_in('Dirección', :with => 'C/El Muro, S/N')
  fill_in('Correo electrónico*', :with => email)
  fill_in('Correo electrónico (repetir)*', :with => email)
  fill_in('Contraseña*', :with => user.password)
  fill_in('Contraseña (repetir)*', :with => user.password)
  check('user_terms_of_service')
  check('user_over_18')
  click_button "Inscribirse"
end

feature "UsersAreParanoid" do
  scenario "create a user", js: true do
    user = FactoryGirl.build(:user)

    create_user_registration(user, user.document_vatid, user.email)
    page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

    create_user_registration(user, user.document_vatid, user.email)
    page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

    create_user_registration(user, user.document_vatid, "trolololo")
    page.must_have_content "La dirección de correo es incorrecta"

    create_user_registration(user, user.document_vatid, "trolololo@example.com")
    page.must_have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
  end
end
