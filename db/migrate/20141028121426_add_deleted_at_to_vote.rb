class AddDeletedAtToVote < ActiveRecord::Migration[4.2]
  def change
    add_column :votes, :deleted_at, :datetime
    add_index :votes, :deleted_at
  end
end
