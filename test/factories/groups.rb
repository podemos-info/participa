FactoryBot.define do
  sequence :name do |n|
    "Nom inventat #{n}"
  end

  sequence :description do |n|
    "Grup molon #{n}"
  end

  factory :group do
    name
    description 
    after(:create) {|group| group.users = [create(:user)]}
  end
end
