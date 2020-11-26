class AddServerToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :server, :string
  end
end
