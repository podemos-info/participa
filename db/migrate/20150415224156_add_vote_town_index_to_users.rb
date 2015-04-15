class AddVoteTownIndexToUsers < ActiveRecord::Migration
  def change
    add_index User, [:vote_town]
  end
end
