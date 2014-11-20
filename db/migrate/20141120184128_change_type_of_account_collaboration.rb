class ChangeTypeOfAccountCollaboration < ActiveRecord::Migration
  def change
    change_column :collaborations, :ccc_account, :bigint    
  end
end
