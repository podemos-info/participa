class AddUserCreatedAtMaxToElections < ActiveRecord::Migration
  def change
    add_column :elections, :user_created_at_max, :date
  end
end
