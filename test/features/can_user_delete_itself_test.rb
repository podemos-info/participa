require "test_helper"

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
    page.driver.block_unknown_urls
    visit proposals_path
    click_button "Apoyar propuesta"
    page.must_have_content "¡Muchas gracias!"
    assert_equal 1, Support.all.count 

    visit edit_user_registration_path
    click_link "Darme de baja" # change tab
    click_button "Darme de baja"
    page.must_have_content "¡Adiós! Tu cuenta ha sido cancelada. Esperamos volver a verte pronto."

    # support should be keeped
    assert_equal 1, Support.all.count 
  end

end 
