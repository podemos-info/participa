# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :vote do
    user
    election
  end
end
