require "test_helper"

if Rails.application.secrets.features["proposals"]

  feature "Proposals" do
    
    scenario "Support", js: true do
      user = FactoryBot.create(:user)
      proposal = FactoryBot.create(:proposal)
  
      login_as(user)
  
      visit proposals_path
  
      page.must_have_content "Iniciativas Ciudadanas"
      
      click_button "Apoyar propuesta"
      page.must_have_content "¡Muchas gracias!"
  
      debugger
      visit proposal_path(id: proposal)
      page.must_have_content "Ya has apoyado esta propuesta. ¡Muchas gracias!"
  
      # TODO Proposal.frozen?
    end
  
  end

end
