class AddUniqueIndexForDeletedAdOnUser < ActiveRecord::Migration
  def up
    add_index :users, [ :deleted_at, :email ], :unique => true
    add_index :users, [ :deleted_at, :phone ], :unique => true
    add_index :users, [ :deleted_at, :document_vatid ], :unique => true
  end

  def down
    remove_index :users, [ :deleted_at, :email ]
    remove_index :users, [ :deleted_at, :phone ]
    remove_index :users, [ :deleted_at, :document_vatid ]
  end
end
