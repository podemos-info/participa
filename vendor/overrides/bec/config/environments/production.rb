Rails.application.configure do
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back t
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = [:es]

  config.action_mailer.delivery_method = :sendmail
end
