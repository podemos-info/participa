class AddCloseMessageToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :close_message, :text
  end
end
