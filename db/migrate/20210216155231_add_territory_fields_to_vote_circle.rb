class AddTerritoryFieldsToVoteCircle < ActiveRecord::Migration
  def change
    add_column :vote_circles, :kind, :integer
    add_column :vote_circles, :country_code, :string
    add_column :vote_circles, :autonomy_code, :string
    add_column :vote_circles, :province_code, :string
  end
end
