require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PodemosJuntos
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'EST'
    config.i18n.default_locale = :es
    config.i18n.available_locales = ['es', 'ca', 'eu']
    config.i18n.fallbacks = [:en] # https://github.com/jim/carmen-rails/issues/13 
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'overlay', 'en', 'world', '*.{rb,yml}').to_s]
  end
end
