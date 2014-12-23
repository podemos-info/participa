# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :election do
    title "Hola mundo"
    agora_election_id 1
    scope 0
    starts_at "2014-09-22 17:01:18"
    ends_at "2014-09-28 17:01:18"
  end
end
