class AddRegionalAssignmentToCollaborations < ActiveRecord::Migration
  def change
    add_column :collaborations, :for_autonomy_cc, :boolean
    add_column :collaborations, :for_town_cc, :boolean
  end
end
