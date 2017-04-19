require 'database_cleaner'

DatabaseCleaner.clean_with :truncation
pw = '123456789'

puts "Creating Users"

admin = FactoryGirl.create(:user, :admin, password: pw, email: "admin@example.com") 
admin.verifications_admin = true
admin.save
puts "Creating admin user with email #{admin.email}"

superadmin = FactoryGirl.create(:user, :superadmin, password: pw, email: "superadmin@example.com") 
puts "Creating superadmin user with email #{superadmin.email}"

groups = []

(0..5).each do |i| 
  group = FactoryGirl.create :group  
  puts "Creating group #{group.name}"
  groups << group
end

(0..10).each do |i| 
  user = FactoryGirl.create(:user, password: pw) 
  user.groups << groups.sample
  puts "Creating unverified user with email #{user.email}"
end

(0..10).each do |i| 
  user = FactoryGirl.create(:user, password: pw) 
  user.verify! user
  puts "Creating verified user with email #{user.email}"
end
