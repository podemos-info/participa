# features/anonimous_user_navigation.feature
Feature: Anonimous user features

  #@javascript
  #Scenario: Navigation to colabora page
  #  Given I navigate to "http://localhost:3000"
  #  When I click on link having text "Colabora periódicamente"
  #  Then element having class "box-ko" should have partial text as "Necesitas iniciar sesión o registrarte para continuar."
   
   #@javascript
   #Scenario: can send microcredit
    # Given there are a microcredit campaing
    # And I maximize browser window
    # And I navigate to "http://localhost:3000"
    # And I click on link having text "Microcréditos"
    # And I wait for 5 sec
    # And I wait 5 seconds for element having class "buttonbox" to display
    # And I forcefully click on element having class "button"
    # And I wait 15 seconds for element having class "modal-dialog" to display
    # And I click on element having id "close-botton"
    # When I enter "Pepito" into input field having name "microcredit_loan[first_name]"
    # And I enter "de los palotes" into input field having name "microcredit_loan[last_name]"
    # And I enter "pepito@palotes.de" into input field having name "microcredit_loan[email]"
    # And I enter "00000010x" into input field having name "microcredit_loan[document_vatid]"
    # And I select "España" option by text from dropdown having name "microcredit_loan[country]"
    # And I wait for 10 sec
    # And I click on element having xpath "//*[@id="select2-chosen-2"]"
    # And I wait for 5 seconds
    # And I enter "Albacete" into input field having id "s2id_autogen2_search"
    # And i click on select2 search
    # And I click on element having class "select2-result-label"
    # And I wait for 5 seconds
    # And I click on element having xpath "/html/body/div[1]/div[2]/div/form/fieldset[2]/div[3]/div/div/span/div/a/span[1]"
    # And I wait for 5 seconds
    # And I enter "Albacete" into input field having css "#select2-drop input"
    # And I click on element having class "select2-result-label"
    # And I wait for 5 sec
    # And I enter "02250" into input field having name "microcredit_loan[postal_code]"
    # And I enter "plaza españa 1" into input field having name "microcredit_loan[address]"
    # And I wait for 5 sec
    # And I forcefully click on element having id "microcredit_loan_amount_500"
    # And I enter "ES1020903200500041045040" into input field having name "microcredit_loan[iban_account]"
    # And I enter "00000000" into input field having name "microcredit_loan[captcha]"
    # And I forcefully click on element having id "microcredit_loan_minimal_year_old"
    # And I forcefully click on element having id "microcredit_loan_terms_of_service"
    # And I scroll to end of page
    # And I wait for 5 sec
    # And I click on element having name "commit"
    # And I wait for 10 sec
    # Then element having class "box-ok" should have partial text as "En unos segundos recibirás un correo electrónico con toda la información necesaria para finalizar el proceso de suscripción del microcrédito Podemos. Por favor, ten en cuenta que es posible que el contador no se actualice de forma inmediata. ¡Gracias por colaborar!"
   
   @javascript
   Scenario: can register
     Given I maximize browser window
     And I navigate to "http://localhost:3000"
     And I wait for 1 sec
     And I click on element having id "close_cookie"
     And I forcefully click on element having css ".intro .buttonbox a.button"
     And I wait for 10 sec
     When I enter "Pepito" into input field having name "user[first_name]"
     And I enter "de los palotes" into input field having name "user[last_name]"
     And I click on element having css "#s2id_user_document_type a"
     And I click on element having css ".select2-result-label"
     And I enter "00000010x" into input field having name "user[document_vatid]"
     And I click on element having css "#user_born_at_input .col-xs-3 a"
     And I click on element having css "#select2-results-2 li:first-of-type"

     And I click on element having css "#user_born_at_input .col-xs-5 a"
     And I click on element having css "#select2-drop li:first-of-type"

     And I click on element having css "#user_born_at_input .col-xs-4 a"
     And I click on element having css "#select2-drop li:first-of-type"

     And I click on element having css "#s2id_user_gender a"
     And I click on element having css ".select2-result-label"

     And I select "España" option by text from dropdown having name "user[country]"
     And I wait for 5 sec
     And I click on element having css "#s2id_user_province .select2-chosen"
     And I wait for 5 seconds
     And I enter "Albacete" into input field having css "#s2id_autogen7_search"
     And i click on select2 search
     And I click on element having class "select2-result-label"
     And I wait for 45 seconds
     And I click on element having css "#s2id_user_town a"
     And I wait for 5 seconds
     And I enter "Albacete" into input field having css "#select2-drop input"
     And I click on element having class "select2-result-label"

