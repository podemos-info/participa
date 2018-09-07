# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :vote do
    user
    election
  end
end
