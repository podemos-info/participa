class CreateParticipationTeams < ActiveRecord::Migration[4.2]
  def change
    create_table :participation_teams do |t|
      t.string :name
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end
