# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    title "MyString"
    id_form 1
    slug "MyString"
    require_login false
  end
end
