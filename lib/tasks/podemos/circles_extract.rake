require 'csv'

namespace :podemos do
  desc "[podemos] Fill data of circles in a file"
  task :create_circles_from_file => :environment do

    path = Rails.root.join('db', 'podemos', "circulos.tsv")

    CSV.foreach(path, :headers => true, :col_sep=> "\t", encoding: "UTF-8") do |row|
      Circle.create(row.to_hash)
    end

  end
end