class AddTownCodeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :town_code, :string
    add_column :orders, :autonomy_code, :string
  end
end
