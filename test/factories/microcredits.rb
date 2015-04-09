# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :microcredit do
    title "Madrid"
    starts_at DateTime.now
    ends_at DateTime.now+1.month
    account_number "XXXXXXXXXX"
    limits "100€: 100\r500€: 22\r1000€: 10"
  end

  trait :expired do
    starts_at DateTime.now-6.month
    ends_at DateTime.now-2.month
  end

end
