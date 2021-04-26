# features/anonimous_user_navigation.feature
Feature: Anonimous user features

  Scenario: Navigation to colabora page
    Given I am on the homepage
    When I click "Colabora periódicamente"
    Then I should see the "Necesitas iniciar sesión o registrarte para continuar." text
   
   @javascript
   Scenario: can send microcredit
     Given there are a microcredit campaing
     Then I maximize browser window
     And I am on the homepage
     When I click "Microcréditos"
     And I click "Quiero colaborar"
     And I click "Continuar sin identificarse"
     And I fill "Microcreditos form"
     Then I Should see "Microcréditos Podemos"
