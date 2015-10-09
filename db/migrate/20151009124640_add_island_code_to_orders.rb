class AddIslandCodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :island_code, :string
  end
end
