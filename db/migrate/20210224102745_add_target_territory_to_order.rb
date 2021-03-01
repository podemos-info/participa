class AddTargetTerritoryToOrder < ActiveRecord::Migration
  def change
    add_column  :orders, :target_territory, :string
  end
end
