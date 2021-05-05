# features/anonimous_user_navigation.feature
Feature: Anonimous user features

  @javascript
  Scenario: Navigation to colabora page
    Given I navigate to "http://localhost:3000"
    When I click on link having text "Colabora periódicamente"
    Then element having class "box-ko" should have partial text as "Necesitas iniciar sesión o registrarte para continuar."
   
   @javascript
   Scenario: can send microcredit
     Given there are a microcredit campaing
     Then I maximize browser window
     And I navigate to "http://localhost:3000"
     When I click on link having text "Microcréditos"
     And I wait for 10 sec
     And I wait 30 seconds for element having class "buttonbox" to display
     And I forcefully click on element having class "button"
     And I wait 30 seconds for element having class "modal-dialog" to display
     And I click on element having id "close-botton"
     And I fill "Microcreditos form"
     Then I Should see "Microcréditos Podemos"
