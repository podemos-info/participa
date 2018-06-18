# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :election do
    title "Hola mundo"
    agora_election_id 1
    scope 0
    starts_at "2014-09-22 17:01:18"
    ends_at "2014-09-28 17:01:18"
    server "agora"
    
    after(:build) { |election| election.election_locations << FactoryBot.create(:election_location, election: election) }
  end

  trait :autonomy do
    scope 1
    after(:build) do |election| 
      election.election_locations.clear
      election.election_locations << FactoryBot.create(:election_location, :autonomy_location, election: election)
    end
  end
  
  trait :province do
    scope 2
    after(:build) do |election| 
      election.election_locations.clear
      election.election_locations << FactoryBot.create(:election_location, :province_location, election: election)
    end
  end

  trait :town do
    scope 3
    after(:build) do |election|
      election.election_locations.clear
      election.election_locations << FactoryBot.create(:election_location, :town_location, election: election)
    end
  end

  trait :island_election do
    scope 4
    after(:build) do |election| 
      election.election_locations.clear
      election.election_locations << FactoryBot.create(:election_location, :island_location, election: election)
    end
  end

  trait :foreign_election do
    scope 5
  end

  trait :beta_server do 
    server "beta"
  end

end
