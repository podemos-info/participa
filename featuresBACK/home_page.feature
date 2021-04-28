# features/home_page.feature
Feature: Home page

  Scenario: Viewing application's home page
    Given I navigate to "http://localhost:3000"
    Then element having class "intro" should have partial text as "Bienvenido/a al Portal de Participación de Podemos."

   Scenario: Login user as test user
     Given there area a test user
     When I fill login form
     Then I Should see "Herramientas de participación ciudadana"
