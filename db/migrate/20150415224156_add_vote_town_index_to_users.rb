class AddVoteTownIndexToUsers < ActiveRecord::Migration[4.2]
  def change
    add_index User, [:vote_town]
  end
end
