class AddParticipationTeamAtToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :participation_team_at, :datetime
  end
end
