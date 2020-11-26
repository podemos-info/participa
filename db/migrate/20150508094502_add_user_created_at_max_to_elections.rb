class AddUserCreatedAtMaxToElections < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :user_created_at_max, :date
  end
end
