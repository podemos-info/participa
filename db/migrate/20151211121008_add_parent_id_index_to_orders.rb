class AddParentIdIndexToOrders < ActiveRecord::Migration
  def change
    add_index Order, [:parent_id]
  end
end
