class AddVoteDistrictToUser < ActiveRecord::Migration
  def change
    add_column :users, :vote_district, :string
  end
end
