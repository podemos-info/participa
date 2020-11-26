class CreateElections < ActiveRecord::Migration[4.2]
  def change
    create_table :elections do |t|
      t.string :title
      t.integer :agora_election_id
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
