require 'rails_helper'

feature "Proposals", js: true do
  
  scenario "Support" do
    user = FactoryGirl.create(:user)
    proposal = FactoryGirl.create(:proposal)

    login_as(user)
    page.driver.block_unknown_urls

    visit proposals_path
    expect(page).to have_content "Iniciativas Ciudadanas"
    
    click_button "Apoyar propuesta"
    expect(page).to have_content "¡Muchas gracias!"

    visit proposal_path(id: proposal)
    expect(page).to have_content "1 de 30.000 Apoyos necesarios"
    expect(page).to have_content "Ya has apoyado esta propuesta. ¡Muchas gracias!"
  end

end