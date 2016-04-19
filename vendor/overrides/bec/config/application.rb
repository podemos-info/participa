module Participa
  class Application < Rails::Application
    config.i18n.default_locale = :es
    config.i18n.available_locales = ['es', 'ca']
    config.to_prepare do
      Devise::Mailer.layout "email"
    end
  end
end
