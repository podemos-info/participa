require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require "minitest/reporters"

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
