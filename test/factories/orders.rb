# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :order do
    collaboration_id 1
    status 1
    payable_at "2014-11-23 00:24:45"
    payed_at "2014-11-23 00:24:45"
    deleted_at "2014-11-23 00:24:45"
  end
end
