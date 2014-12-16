class AddWantsParticipationToUser < ActiveRecord::Migration
  def change
    add_column :users, :wants_participation, :boolean
  end
end
