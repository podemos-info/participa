gherkin
# features/home_page.feature
Feature: Home page

  Scenario: Viewing application's home page
    When I am on the homepage
    Then I should see the "My first" post