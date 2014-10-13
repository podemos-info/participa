Recaptcha.configure do |config|
  config.public_key  = Rails.application.secrets.recaptcha['public']
  config.private_key = Rails.application.secrets.recaptcha['private']
end
