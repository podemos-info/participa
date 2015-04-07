
namespace :test do
  Rails::TestTask.new("features" => "test:prepare") do |t|
    t.pattern = "test/features/**/*_test.rb"
  end
end

Rake::Task["test:run"].enhance ["test:features"]

