
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'simplecov'
require 'webmock/minitest'
require "minitest/reporters"

SimpleCov.start
WebMock.disable_net_connect!(allow_localhost: true)
Minitest::Reporters.use!

class ActionController::TestCase
  include Devise::TestHelpers
  include FactoryGirl::Syntax::Methods
end


def with_blocked_change_location
	begin
		Rails.application.secrets.users["allows_location_change"] = false
		yield
	ensure
		Rails.application.secrets.users["allows_location_change"] = true
	end
end
