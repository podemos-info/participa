# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :microcredit_loan do
    association :microcredit
    association :user
    amount 100
  end

end
