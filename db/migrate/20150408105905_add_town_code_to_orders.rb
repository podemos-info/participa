class AddTownCodeToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :town_code, :string
    add_column :orders, :autonomy_code, :string
  end
end
