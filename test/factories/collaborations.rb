# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    association :user, :factory => [:user]
    amount 1000
    frequency 1
    payment_type 2
    ccc_entity '9000'
    ccc_office '0001'
    ccc_dc '21'
    ccc_account '0123456789'
  end

  trait :credit_card do
    association :user, :factory => [:user]
    payment_type 1
    ccc_entity nil
    ccc_office nil
    ccc_dc nil
    ccc_account nil
  end

  trait :foreign_user do 
    association :user, :factory => [:user, :foreign]
  end

  trait :june2014 do
    created_at DateTime.new(2014,6,1)
  end

  trait :quarterly do
    frequency 3
  end

  trait :yearly do
    frequency 12
  end
end
