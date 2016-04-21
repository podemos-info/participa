Rails.application.configure do

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back t
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = [:es]

  config.action_mailer.delivery_method = :sendmail

  #ActionMailer::Base.delivery_method = :smtp
  #ActionMailer::Base.smtp_settings = {
  #  :address        => 'in-v3.mailjet.com',
  #  :enable_starttls_auto => true,
  #  :port           => 587,
  #  :authentication => :plain,
  #  :user_name      => Rails.application.secrets.mailjet["api_key"],
  #  :password       => Rails.application.secrets.mailjet["secret_key"],
  #  :domain         => 'barcelonaencomu.cat'
  #}

end
