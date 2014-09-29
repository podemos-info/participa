class CreateCollaborations < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
      t.integer :user_id
      t.integer :amount
      t.integer :frequency
      t.string :order
      t.datetime :response_recieved_at
      t.string :response_code
      t.string :response_status
      t.text :response

      t.timestamps
    end
  end
end
