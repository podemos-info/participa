class ModifyResultFieldToStatusFieldUserVerifications < ActiveRecord::Migration
  def change
    remove_column :user_verifications, :result, :boolean
    add_column :user_verifications, :status, :integer, default: 0
  end
end
