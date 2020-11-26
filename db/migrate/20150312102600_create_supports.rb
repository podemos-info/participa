class CreateSupports < ActiveRecord::Migration[4.2]
  def change
    create_table :supports do |t|
      t.integer :user_id
      t.integer :proposal_id

      t.timestamps
    end
  end
end
