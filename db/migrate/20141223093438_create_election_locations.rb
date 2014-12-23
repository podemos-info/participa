class CreateElectionLocations < ActiveRecord::Migration
  def change
    create_table :election_locations do |t|
      t.integer :election_id
      t.string :location

      t.timestamps
    end
  end
end
