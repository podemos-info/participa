class AddVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :verified_by_id, :integer
    add_column :users, :verified_at, :datetime
  end
end
