class AddVoteDistrictToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :vote_district, :string
  end
end
