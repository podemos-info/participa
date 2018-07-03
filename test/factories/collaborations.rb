# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :collaboration do
    payment_type 1
    association :user
    amount 1000
    frequency 1
  end

  trait :ccc do 
    payment_type 2
    ccc_entity '9000'
    ccc_office '0001'
    ccc_dc '21'
    ccc_account '0123456789'
  end
  
  trait :iban do 
    payment_type 3
    iban_account "ES0690000001210123456789"
    iban_bic "ESPBESMMXXX"
  end

  trait :credit_card do
    payment_type 1
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
