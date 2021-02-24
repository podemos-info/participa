class AddVoteCircleCodeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :vote_circle_id, :integer
  end
end
