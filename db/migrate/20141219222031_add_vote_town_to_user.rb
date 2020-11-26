class AddVoteTownToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :vote_town, :string
  end
end
