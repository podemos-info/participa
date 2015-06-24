class AddParticipationTeamAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :participation_team_at, :datetime
  end
end
