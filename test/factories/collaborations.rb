# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    user
    amount 1000
    frequency 120
  end
end
