require "test_helper"

feature "ParticipationTeams" do
  
  scenario "can't access as anon, can join, can delete itself", js: true do
    user = FactoryBot.create(:user)
  
    visit participation_teams_path
    page.must_have_content "Necesitas iniciar sesión o registrarte para continuar."

    login_as(user)
    visit participation_teams_path
    page.must_have_content "Incorpórate a los Equipos de Acción Participativa"
    
    click_link "¡Únete", match: :first
    page.must_have_content "Te damos la bienvienida a los Equipos de Acción Participativa. En los próximos días nos pondremos en contacto contigo."

    click_link "Darme de baja"
    page.must_have_content "Te has dado de baja de los Equipos de Acción Participativa"
  end

end
