# features/step_definitions/home_page_steps.rb

Given(/^I am on the homepage$/) do
  visit root_path
end

Then(/^I should see the "(.*?)" /) do |title|

  page.should have_content(title)
end