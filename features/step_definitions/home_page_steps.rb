# features/step_definitions/home_page_steps.rb


Given(/^I am on the homepage$/) do
  log(page.driver)
  page.driver.browser.manage.window.resize_to(1920, 1080)
  navigate_to("/")
end

Then(/^I should see the "(.*?)" /) do |title|

  page.should have_content(title)
end

Given('there area a test user') do
  @user = FactoryBot.create(:user)
  
end

When('I fill login form') do
  visit("/")
  within("#new_user") do
    fill_in 'user[login]', with: 'foo1@example.com'
    fill_in 'user[password]', with: '123456789'
  end
  click_button 'Iniciar sesión'
end

Then('I Should see {string}') do |string|
  page.should have_content(string)
end
