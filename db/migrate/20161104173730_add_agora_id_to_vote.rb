class AddAgoraIdToVote < ActiveRecord::Migration
  def change
    add_column :votes, :agora_id, :integer
  end
end
