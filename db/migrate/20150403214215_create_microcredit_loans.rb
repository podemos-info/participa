class CreateMicrocreditLoans < ActiveRecord::Migration
  def change
    create_table :microcredit_loans do |t|
      t.integer :microcredit_id
      t.integer :amount
      t.integer :user_id
      t.text :user_data
      t.datetime :confirmed_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
