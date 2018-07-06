# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do


  sequence :ip do |n|
    "1.2.3.#{n}"
  end

  factory :microcredit_loan do
    association :microcredit
    association :user
    amount 100
    ip
  end

end
