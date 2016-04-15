require "test_helper"

feature "Active Admin Test" do

  scenario "normal user shouldn't access the admin" do
    visit admin_users_path
    page.must_have_content "No tienes permisos para acceder a esa sección "

    user = FactoryGirl.create(:user)
    login_as(user)
    visit admin_collaborations_path
    page.must_have_content "No tienes permisos para acceder a esa sección "
  end

  scenario "admin user should access the admin" do
    user = FactoryGirl.create(:user, :admin)
    login_as(user)
    visit admin_users_path
    page.must_have_content "Salir"
    page.must_have_content "Usuario"
    page.must_have_content "Perez Pepito"
  end

end 
