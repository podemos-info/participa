
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'simplecov'
require 'webmock/minitest'
require 'minitest/reporters'
require 'minitest/rails/capybara'

SimpleCov.start
WebMock.disable_net_connect!(allow_localhost: true)
Minitest::Reporters.use!
Capybara.javascript_driver = :webkit
include Warden::Test::Helpers
Warden.test_mode!

class ActionController::TestCase
  include Devise::TestHelpers
  include FactoryBot::Syntax::Methods
end

def with_blocked_change_location
  begin
    Rails.application.secrets.users["allows_location_change"] = false
    yield
  ensure
    Rails.application.secrets.users["allows_location_change"] = true
  end
end

# FIX Capybara error: SQLite3::BusyException: database is locked
# http://atlwendy.ghost.io/capybara-database-locked/
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

def with_versioning
  was_enabled = PaperTrail.enabled?
  was_enabled_for_controller = PaperTrail.enabled_for_controller?
  PaperTrail.enabled = true
  PaperTrail.enabled_for_controller = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
    PaperTrail.enabled_for_controller = was_enabled_for_controller
  end
end