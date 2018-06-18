# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :participation_team do
    name "Super team"
    description "Very very long description "*100
    active true
  end
end
