class AddWantsParticipationToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :wants_participation, :boolean
  end
end
