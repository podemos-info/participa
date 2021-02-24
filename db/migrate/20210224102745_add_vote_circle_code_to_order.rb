class AddVoteCircleCodeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :vote_circle_id, :numeric
  end
end
