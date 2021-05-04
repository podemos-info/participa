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
     And I click on link having text "Quiero colaborar"
     And I click on link having text "Continuar sin identificarse"
     And I fill "Microcreditos form"
     Then I Should see "Microcréditos Podemos"
