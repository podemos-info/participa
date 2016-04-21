Mailjet.configure do |config|
  config.api_key = Rails.application.secrets.mailjet["api_key"]
  config.secret_key =  Rails.application.secrets.mailjet["secret_key"]
  config.default_from = Rails.application.secrets.mailjet["default_from"]
end
