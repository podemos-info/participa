Esendex.configure do |config|
  config.username = Rails.application.secrets.esendex["username"]
  config.password = Rails.application.secrets.esendex["password"]
  config.account_reference = Rails.application.secrets.esendex["account_reference"]
end
