# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    association :user, :factory => [:user, :dni]
    amount 1000
    frequency 1
    payment_type 2
    ccc_entity '9000'
    ccc_office '0001'
    ccc_dc '21'
    ccc_account '0123456789'
  end

  trait :foreign_user do 
    user
  end

end
