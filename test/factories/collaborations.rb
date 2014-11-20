# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaboration do
    user
    amount 1000
    frequency 120
    payment_type 2
    ccc_entity '2177'
    ccc_office '0993'
    ccc_dc '23'
    ccc_account '2366217197'
  end
end
