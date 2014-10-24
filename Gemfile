source 'https://rubygems.org'

gem 'rails', '4.1.5'
gem 'sqlite3'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer',  platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development

gem 'unicorn'
gem 'pg'
gem 'rb-readline'
gem 'airbrake'

gem 'devise'
gem 'cancancan', '~> 1.9'
gem 'bootstrap-sass'
gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'spanish_vat_validators'
gem 'recaptcha', :require => 'recaptcha/rails'
gem 'carmen-rails'
gem 'esendex'
gem 'activeadmin', github: 'activeadmin'
gem 'active_skin'
gem 'mailcatcher' # for staging too
gem 'resque', github: 'resque/resque', branch: '1-x-stable', require: 'resque/server'
gem 'resque-pool'
gem 'aws-ses', '~> 0.5.0', :require => 'aws/ses'
gem 'kaminari'
gem 'pushmeup'
gem 'date_validator'

# FIXME we use a fork for this issue with uniqueness
# https://github.com/radar/paranoia/issues/114
# https://github.com/radar/paranoia/pull/121
# 
# In the future it'll be merged and everything will be OK. Meanwhile check:
# * the validations on user uniqueness (scope: deleted_at), 
# * active_admin default scope
# * and tests on test/models/user_test.rb ("should act_as_paranoid" and "should scope uniqueness with paranoia")
# 
# gem 'paranoia', '~> 2.0' 
gem 'paranoia', :github => 'codeodor/paranoia', :branch => 'rails4'

group :development, :test do
  gem 'pry'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'factory_girl_rails'
  gem 'byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails-perftest'
  gem 'ruby-prof'
end

