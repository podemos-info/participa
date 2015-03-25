class AddServerToElection < ActiveRecord::Migration
  def change
    add_column :elections, :server, :string
  end
end
