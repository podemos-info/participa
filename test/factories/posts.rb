# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :post do
    title "MyString"
    content "MyText"
    slug "MyString"
    status 1
  end
end
