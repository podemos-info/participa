class RenameCircleToVoteCircle < ActiveRecord::Migration
  def change
    rename_table :circles, :vote_circles
  end
end
