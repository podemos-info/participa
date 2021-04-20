# features/home_page.feature
Feature: Home page

  Scenario: Viewing application's home page
    Given I am on the homepage
    Then I should see the "Bienvenido/a al Portal de Participación de Podemos." text

   Scenario: Login user as test user
     Given there area a test user
     When I fill login form
     Then I Should see "Herramientas de participación ciudadana"
