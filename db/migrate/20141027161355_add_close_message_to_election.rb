class AddCloseMessageToElection < ActiveRecord::Migration
  def change
    add_column :elections, :close_message, :text
  end
end
