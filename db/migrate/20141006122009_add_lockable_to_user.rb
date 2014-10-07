class AddLockableToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :failed_attempts, :integer, :default => 0, :null => false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime
  end

  def self.down
    remove_columns :users, :failed_attempts, :unlock_token, :locked_at
  end
end
