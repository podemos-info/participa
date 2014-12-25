class AddVoteTownToUser < ActiveRecord::Migration
  def change
    add_column :users, :vote_town, :string
  end
end
