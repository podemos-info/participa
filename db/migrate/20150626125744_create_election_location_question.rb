class CreateElectionLocationQuestion < ActiveRecord::Migration
  def change
    create_table :election_location_questions do |t|
      t.references :election_location
      t.string :title
      t.text :description
      t.string :voting_system
      t.string :layout
      t.integer :winners
      t.integer :minimum
      t.integer :maximum
      t.boolean :random_order
      t.string :totals
      t.text :options
    end
  end
end
