FactoryGirl.define do

  sequence :email do |n|
    "foo#{n}@example.com"
  end

  factory :user do
    last_name "Pepito"
    first_name "Perez"
    email 
    password '123456789'
    confirmed_at Time.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 3
    document_vatid '83482396D'
    admin false
    address "C/ Inventada, 123" 
    town "Madrid"
    province "M"
    postal_code "28021"
    country "ES"
    phone "003466111111111"
    sms_confirmed_at DateTime.now
  end

  factory :admin, class: User do
    last_name "Juan"
    first_name "Eladmin"
    email 
    password '123456789'
    confirmed_at Time.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 3
    document_vatid '2221X'
    admin true
    address "C/ Inventada, 123" 
    town "Madrid"
    province "M"
    postal_code "28021"
    country "ES"
    phone "00346666666"
    sms_confirmed_at DateTime.now
  end

  factory :legacy_password_user, class: User do
    last_name "Juan"
    first_name "Password Legacy"
    email 
    password '123456789'
    confirmed_at Time.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 3
    document_vatid '2221X'
    admin true
    address "C/ Inventada, 123" 
    town "Madrid"
    province "M"
    postal_code "28021"
    country "ES"
    phone "00346666666"
    sms_confirmed_at DateTime.now
    has_legacy_password true
  end

  factory :sms_confirmed_user, class: User do
    last_name "Juan"
    first_name "SMS confirmed user"
    email 
    password '123456789'
    confirmed_at Time.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 3
    document_vatid '2221X'
    admin true
    address "C/ Inventada, 123" 
    town "Madrid"
    province "M"
    postal_code "28021"
    country "ES"
  end

end
