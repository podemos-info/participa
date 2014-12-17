class RenameRedsysFieldsOnCollaboration < ActiveRecord::Migration
  def change
    rename_column :collaborations, :response, :redsys_response
    rename_column :collaborations, :response_code, :redsys_response_code
    rename_column :collaborations, :response_recieved_at, :redsys_response_recieved_at
  end
end
