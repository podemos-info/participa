require "test_helper"

feature "Microcredits" do

  scenario "new loan - anonymous user" do
    skip
    #microcredit = FactoryGirl.create(:microcredit)
    #user = FactoryGirl.build(:user)

    #visit microcredit_path
    #page.must_have_content "Ayúdanos a financiar las campañas electorales"
    #page.must_have_content microcredit.title

    #click_link "Quiero colaborar"
    #page.must_have_content "Acepto la suscripción de un contrato civil de préstamo por el importe indicado"

    #click_button "Suscribir"
    #page.must_have_content "no puede estar en blanco"

    #fill_in('Nombre', :with => 'John')
    #fill_in('Apellidos', :with => 'Snow')
    #select('Madrid', :from=>'Provincia')
    #fill_in('Municipio', :with=>'Madrid')
    ##select('Madrid', :from=>'Municipio')
    #fill_in('Código postal', :with => '28021')
    #fill_in('Dirección', :with => 'C/El Muro, S/N')
    #fill_in('DNI', :with => user.document_vatid)
    #fill_in('Correo electrónico', :with => 'john@snow.com')
    #choose('microcredit_loan_amount_100')
    #check('microcredit_loan_minimal_year_old')
    #check('microcredit_loan_terms_of_service')

    #click_button "Suscribir"
    #page.must_have_content "En unos segundos recibirás un correo electrónico con toda la información necesaria para finalizar el proceso de suscripción del microcrédito Podemos"
  end

  scenario "new loan - logged in user" do
    skip 
    #microcredit = FactoryGirl.create(:microcredit)
    #user = FactoryGirl.create(:user)

    #login_as(user)
    #visit microcredit_path
    #page.must_have_content "Ayúdanos a financiar las campañas electorales"
    #page.must_have_content microcredit.title

    #click_link "Quiero colaborar"
    #page.must_have_content "Acepto la suscripción de un contrato civil de préstamo por el importe indicado"

    #click_button "Suscribir"
    #page.must_have_content "no puede estar en blanco"

    #choose('microcredit_loan_amount_100')
    #check('microcredit_loan_minimal_year_old')
    #check('microcredit_loan_terms_of_service')

    #click_button "Suscribir"
    #page.must_have_content "En unos segundos recibirás un correo electrónico con toda la información necesaria para finalizar el proceso de suscripción del microcrédito Podemos"
  end

end
