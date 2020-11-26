class AddFlagsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :flags, :integer, null: false, default: 0
    add_index :users, :flags
  end
end
