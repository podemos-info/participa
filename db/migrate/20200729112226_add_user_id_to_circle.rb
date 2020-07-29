class AddUserIdToCircle < ActiveRecord::Migration
  def change
    add_column :circles, :user_id, :integer
  end
end
