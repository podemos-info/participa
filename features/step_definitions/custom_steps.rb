require 'selenium-cucumber'


# Do Not Remove This File
# Add your custom steps here
# $driver is instance of webdriver use this instance to write your custom code

Given('there are a microcredit campaing') do
  FactoryBot.create(:microcredit)
end

When('I click {string}') do |string|
  click_link string
end

When('I fill {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('I Should see {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
