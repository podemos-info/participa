class ChangeVoteCirclesFieldsInUsers < ActiveRecord::Migration
  def change
    remove_column :users, :circle_id, :integer
    add_column :users, :vote_circle_id, :integer
    remove_column :users, :circle_changed_at, :datetime
    add_column :users, :vote_circle_changed_at, :datetime
  end
end
