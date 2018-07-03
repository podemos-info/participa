FactoryBot.define do

  factory :application, class: Doorkeeper::Application do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri 'https://app.com/callback'
  end

  factory :access_token, class: Doorkeeper::AccessToken do
    sequence(:resource_owner_id) { |n| n }
    application
    expires_in 2.hours
  end

end
