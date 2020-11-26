class AddAgoraIdToVote < ActiveRecord::Migration[4.2]
  def change
    add_column :votes, :agora_id, :integer
  end
end
