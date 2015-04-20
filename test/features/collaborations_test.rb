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



    #visit new_collaboration_path
    #select('5 €', :from=>'Importe mensual') 
    #fill_in('#collaboration_ccc_entity', with: '2222')
    #fill_in('#collaboration_ccc_office', with: '2222')
    #fill_in('#collaboration_ccc_dc', with: '91')
    #fill_in('#collaboration_ccc_account', with: '919191911991')
    #select('Mensual', :from=>'Frecuencia de pago') 
    #select('Domiciliación en cuenta bancaria (formato CCC)', :from=>'Método de pago') 
    #check('collaboration_minimal_year_old')
    #check('collaboration_terms_of_service')
    #click_button("Guardar Colaboración económica")
    #save_and_open_page


end
