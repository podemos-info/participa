class AddVoteCircleTerritoriesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :vote_circle_autonomy_code, :string
    add_column :orders, :vote_circle_town_code, :string
    add_column :orders, :vote_circle_island_code, :string
  end
end
