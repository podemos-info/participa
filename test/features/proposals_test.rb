require "test_helper"

feature "Proposals" do
  
  scenario "Support", js: true do
    user = FactoryGirl.create(:user)
    proposal = FactoryGirl.create(:proposal)

    login_as(user)
    page.driver.block_unknown_urls

    visit proposals_path
    page.must_have_content "Iniciativas Ciudadanas"
    
    click_button "Apoyar propuesta"
    page.must_have_content "¡Muchas gracias!"

    visit proposal_path(id: proposal)
    page.must_have_content "Ya has apoyado esta propuesta. ¡Muchas gracias!"
  end

end
