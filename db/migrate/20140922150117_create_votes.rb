class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :election_id
      t.string  :voter_id

      t.timestamps
    end
  end
end
