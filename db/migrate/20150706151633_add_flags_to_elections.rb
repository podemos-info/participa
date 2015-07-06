class AddFlagsToElections < ActiveRecord::Migration
  def change
    add_column :elections, :flags, :integer
  end
end
