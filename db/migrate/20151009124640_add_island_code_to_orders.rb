class AddIslandCodeToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :island_code, :string
  end
end
