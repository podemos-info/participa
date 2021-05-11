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

When('i click on select2 search') do
  element = $driver.find_elements(:css, '#select2-drop .select2-search')
  $driver.action.click(element)
end
