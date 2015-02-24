# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participation_team do
    name "Super team"
    description "Very very long description "*100
    active true
  end
end
