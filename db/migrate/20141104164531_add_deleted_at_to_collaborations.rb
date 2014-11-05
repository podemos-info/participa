class AddDeletedAtToCollaborations < ActiveRecord::Migration
  def change
    add_column :collaborations, :deleted_at, :datetime
    add_index :collaborations, :deleted_at
  end
end
