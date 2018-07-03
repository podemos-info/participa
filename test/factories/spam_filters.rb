# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :spam_filter do
    name "Test"
    code "true"
    data ""
    query ""
    active true
  end
end
