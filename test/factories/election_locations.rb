# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :election_location do
    election
    location "00"
    agora_version 0
  end

  trait :autonomy_location do
    location "11"
    agora_version 1
  end
  
  trait :province_location do
    location "28"
    agora_version 0
  end

  trait :town_location do
    location "280796"
    agora_version 0
  end

  trait :island_location do
    location "73"
    agora_version 0
  end
end
