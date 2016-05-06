FactoryGirl.define do

  sequence :email do |n|
    "foo#{n}@example.com"
  end

  sequence :document_vatid do |n|
    "#{n.to_s.rjust(8,'0')}#{'TRWAGMYFPDXBNJZSQVHLCKE'[n % 23].chr}"
  end

  sequence :phone do |n|
    "0034661#{n.to_s.rjust(6, "1")}"
  end

  factory :user do
    last_name "Pepito"
    first_name "Perez"
    # FIXME: reutilice email_confirmation
    email 
    email_confirmation { email }
    password '123456789'
    confirmed_at Time.now
    born_at Date.civil(1983, 2, 1) 
    wants_newsletter true
    document_type 1
    document_vatid 
    admin false
    address "C/ Inventada, 123" 
    country "ES"
    province "M"
    town "m_28_079_6"
    vote_town "m_28_079_6"
    postal_code "28021"
    phone
    sms_confirmed_at DateTime.now
    flags 0
  end

  trait :admin do
    admin true
  end

  trait :superadmin do
    superadmin true
  end

  trait :legacy_password_user do
    has_legacy_password true
  end

  trait :sms_non_confirmed_user do
    sms_confirmed_at nil
  end

  trait :no_newsletter_user do
    wants_newsletter false
  end

  trait :newsletter_user do
    wants_newsletter true
  end

  trait :foreign do
    document_type 3
    sequence(:document_vatid) { |n| "83482#{n}D" }
  end

  trait :foreign_address do
    country "US"
    province "AL"
    town "Jefferson County"
  end

  trait :island do
    province "IB"
    postal_code "07021"
    town "m_07_003_3"
  end
end
