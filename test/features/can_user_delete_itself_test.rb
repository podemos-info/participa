require "test_helper"

def create_resource_and_delete_itself klass, factory, final_count
  # Collaboration, :collaboration, 0
  scenario "a logged in user should delete itself after making a #{klass}", js: true do
    assert_equal 0, klass.all.count 
    resource = FactoryGirl.create(factory)
    assert_equal 1, klass.all.count 

    login_as(resource.user)
    visit edit_user_registration_path
    click_link "Darme de baja" # change tab
    click_button "Darme de baja"
    page.must_have_content "¡Adiós! Tu cuenta ha sido cancelada. Esperamos volver a verte pronto."

    # resource should be deleted
    assert_equal final_count, klass.all.count 
  end
end

feature "CanUserDeleteItselfTest" do

  scenario "a logged in user should delete itself" do
    assert_equal 0, User.all.count 
    user = FactoryGirl.create(:user)
    assert_equal 1, User.all.count 

    login_as(user)
    visit edit_user_registration_path
    page.must_have_content "Darme de baja"

    click_button "Darme de baja"
    page.must_have_content "¡Adiós! Tu cuenta ha sido cancelada. Esperamos volver a verte pronto."
    assert_equal 0, User.all.count 
    assert_equal 1, User.with_deleted.count
    u = User.with_deleted.first
    assert u.deleted_at?
  end

  scenario "a logged in user should delete itself after making a support on a proposal", js: true do
    assert_equal 0, Support.all.count 
    proposal = FactoryGirl.create(:proposal)
    user = FactoryGirl.create(:user)

    login_as(user)
    visit proposals_path
    click_button "Apoyar propuesta"
    page.must_have_content "¡Muchas gracias!"
    assert_equal 1, Support.all.count 

    visit edit_user_registration_path
    click_link "Darme de baja" # change tab
    click_button "Darme de baja"
    page.must_have_content "¡Adiós! Tu cuenta ha sido cancelada. Esperamos volver a verte pronto."

    # resource should be deleted
    assert_equal 0, Support.all.count 
  end

  # a user should delete itself and delete their collaboration
  create_resource_and_delete_itself Collaboration, :collaboration, 0

  # a user should delete itself and keep their microcredit loan
  create_resource_and_delete_itself MicrocreditLoan, :microcredit_loan, 1

  # a user should delete itself and delete their vote
  create_resource_and_delete_itself Vote, :vote, 0

end 
