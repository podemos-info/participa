# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
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

  trait :non_user do
    user nil
    non_user_document_vatid "XXXXXXXXX"
    non_user_email "pepito@example.com"
    non_user_data "--- !ruby/object:Collaboration::NonUser
legacy_id: 1
full_name: XXXXXXXXXXXXXXXXX
document_vatid: XXXXXXXXX
email: pepito@example.com
address: Av. Siempreviva 123
town_name: Madrid
postal_code: '28024'
country: ES
province: 'Madrid'
phone: '666666'"
  end
end
