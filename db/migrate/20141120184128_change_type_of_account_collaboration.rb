class ChangeTypeOfAccountCollaboration < ActiveRecord::Migration[4.2]
  def change
    change_column :collaborations, :ccc_account, :bigint    
  end
end
