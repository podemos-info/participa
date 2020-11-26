class RegenerateIndexOnUsersEmail < ActiveRecord::Migration[4.2]
  # remove unique index for email, see paranoia/acts_as_paranoid on user.email
  # and uniqueness rules for deleted_at
  def up 
    remove_index :users, :email
    add_index :users, :email
  end

  def down 
    remove_index :users, :email
    add_index :users, :email, :unique => true
  end
end
