class AddInsularAssignmentToCollaborations < ActiveRecord::Migration[4.2]
  def change
      add_column :collaborations, :for_island_cc, :boolean
  end
end
