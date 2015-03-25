require 'reddit'

namespace :podemos do
  desc "[podemos] Extract best proposals from Reddit - Plaza Podemos"
  task :reddit => :environment do
    plaza_podemos = Reddit.new("Podemos")
    plaza_podemos.extract
  end
end