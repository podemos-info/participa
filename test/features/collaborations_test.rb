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
  end

  scenario "a user should be able to add and destroy a new collaboration" do
    user = FactoryGirl.create(:user)
    assert_equal 0, Collaboration.all.count 

    # logged in user, fill collaboration
    login_as(user)
    visit new_collaboration_path
    #page.must_have_content "Colaborando con Podemos conseguirás que este proyecto siga creciendo mes a mes"
    page.must_have_content "Apúntate a las donaciones periódiques de BComú"
    select('500', :from=>'Importe mensual') 
    select('Trimestral', :from=>'Frecuencia de pago') 
    select('Domiciliación en cuenta bancaria (formato IBAN)', :from=>'Método de pago') 
    fill_in('collaboration_iban_account', :with => "ES0690000001210123456789")
    fill_in('collaboration_iban_bic', :with => "ESPBESMMXXX")
    check('collaboration_terms_of_service')
    check('collaboration_minimal_year_old') 

    click_button "Guardar Colaboración económica"
    page.must_have_content "6.000,00€"
    assert_equal 1, Collaboration.all.count 

    # confirm collaboration
    click_link "Confirmar"
    page.must_have_content "Tu donación se ha dado de alta correctamente."

    # modify collaboration
    visit new_collaboration_path
    page.must_have_content "Ya tienes una colaboración"

    # destroy collaboration
    click_link "Dar de baja colaboración"
    page.must_have_content "Hemos dado de baja tu colaboración."
    assert_equal 0, Collaboration.all.count 
  end

  scenario "a user should be able to add and destroy a new collaboration with orders" do
    user = FactoryGirl.create(:user)
    assert_equal 0, Collaboration.all.count 

    login_as(user)
    visit new_collaboration_path
    #page.must_have_content "Colaborando con Podemos conseguirás que este proyecto siga creciendo mes a mes"
    page.must_have_content "Apúntate a las donaciones periódiques de BComú"

    select('500', :from=>'Importe mensual') 
    select('Trimestral', :from=>'Frecuencia de pago') 
    select('Domiciliación en cuenta bancaria (formato IBAN)', :from=>'Método de pago') 
    fill_in('collaboration_iban_account', :with => "ES0690000001210123456789")
    fill_in('collaboration_iban_bic', :with => "ESPBESMMXXX")
    check('collaboration_terms_of_service')
    check('collaboration_minimal_year_old') 

    click_button "Guardar Colaboración económica"
    page.must_have_content "6.000,00€"
    assert_equal 1, Collaboration.all.count 

    click_link "Confirmar"
    page.must_have_content "Tu donación se ha dado de alta correctamente."

    # modify collaboration
    visit new_collaboration_path
    page.must_have_content "Ya tienes una colaboración"

    collaboration = Collaboration.all.last
    order = collaboration.create_order Date.today+1.day
    assert order.save
    assert_equal 1, Order.all.count

    # destroy collaboration
    click_link "Dar de baja colaboración"
    page.must_have_content "Hemos dado de baja tu colaboración."

    assert_equal 0, Collaboration.all.count 
    assert_equal 1, Order.all.count
  end

end
