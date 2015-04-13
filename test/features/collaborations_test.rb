require "test_helper"

feature "Collaborations" do
  scenario "new collaboration" do
    # anonymous
    visit new_collaboration_path
    page.must_have_content "Necesitas iniciar sesión o registrarte para continuar."

    # logged in user (no collaboration)
    user = FactoryGirl.create(:user)
    login_as(user)
    visit new_collaboration_path
    page.must_have_content "Declaro ser mayor de 18 años."

    # logged in user (with unconfirmed collaboration)
    collaboration = FactoryGirl.create(:collaboration, user: user)
    visit new_collaboration_path
    page.must_have_content "Revisa y confirma todos los datos para activar la colaboración."

    # logged in user (with confirmed collaboration)
    # TODO
  end
end
