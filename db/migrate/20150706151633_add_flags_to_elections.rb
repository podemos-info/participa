class AddFlagsToElections < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :flags, :integer
  end
end
