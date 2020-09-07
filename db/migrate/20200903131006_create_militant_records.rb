class CreateMilitantRecords < ActiveRecord::Migration
  def change
    create_table :militant_records do |t|
      t.integer :user_id
      t.datetime :begin_verified
      t.datetime :end_verified
      t.datetime :begin_in_circle
      t.datetime :end_in_circle
      t.datetime :begin_payment
      t.datetime :end_payment
      t.string :circle_name
      t.integer :payment_type
      t.integer :amount
      t.boolean :is_militant

      t.timestamps null: false
    end
  end
end
