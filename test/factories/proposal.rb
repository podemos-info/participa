# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :proposal do
    title 'Change the world'
    description 'We should do this'
    reddit_threshold true
  end
end