class AddTerritoryFieldsToVoteCircle < ActiveRecord::Migration
  def change
    add_column :vote_circles, :kind, :numeric
    add_column :vote_circles, :country_code, :string
    add_column :vote_circles, :autonomy_code, :string
    add_column :vote_circles, :province_code, :string
  end
end
