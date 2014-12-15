# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    user
    amount 1000
    frequency 1
    payment_type 2
    ccc_entity '2177'
    ccc_office '0993'
    ccc_dc '23'
    ccc_account '2366217197'
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
