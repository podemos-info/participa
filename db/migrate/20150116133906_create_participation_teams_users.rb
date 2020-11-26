class CreateParticipationTeamsUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :participation_teams_users, id: false do |t|
      t.integer :participation_team_id
      t.integer :user_id
    end
    add_index :participation_teams_users, :participation_team_id
    add_index :participation_teams_users, :user_id
  end
end
