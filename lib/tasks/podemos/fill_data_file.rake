require 'podemos_export'

namespace :podemos do

  desc "[podemos] Fill data of users in a file"
  task :fill_data_file, [:input_file] => :environment do |t,args|

    args.with_defaults(:input_file => nil)

    fill_data args.input_file, User.confirmed

  end

end

