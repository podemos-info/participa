class AddOverrideToElectionLocation < ActiveRecord::Migration
  def change
    add_column :election_locations, :override, :string
  end
end
