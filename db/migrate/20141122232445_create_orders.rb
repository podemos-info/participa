class CreateOrders < ActiveRecord::Migration[4.2]
  def change
    create_table :orders do |t|
      t.integer :collaboration_id
      t.integer :status
      t.datetime :payable_at
      t.datetime :payed_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
