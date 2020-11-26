class ChangeUserCreatedAtMaxTypeInElections < ActiveRecord::Migration[4.2]
  def self.up
    change_column :elections, :user_created_at_max, :datetime
  end
  def self.down
    change_column :elections, :user_created_at_max, :date
  end
end
