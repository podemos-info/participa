class AddCensusFileToElection < ActiveRecord::Migration
  def change
    add_attachment :elections, :census_file
  end
end
