class AddPriorityToUserVerifications < ActiveRecord::Migration[4.2]
  def change
    add_column :user_verifications, :priority, :integer, default: 0, null: false
  end
end
