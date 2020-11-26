class AddParentIdIndexToOrders < ActiveRecord::Migration[4.2]
  def change
    add_index Order, [:parent_id]
  end
end
