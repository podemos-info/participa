Given('there are a microcredit campaing') do
  FactoryBot.create(:microcredit)
end

When('I click {string}') do |string|
  click_link string
end

When('I fill {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
