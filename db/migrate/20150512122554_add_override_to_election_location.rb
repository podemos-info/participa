class AddOverrideToElectionLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :election_locations, :override, :string
  end
end
