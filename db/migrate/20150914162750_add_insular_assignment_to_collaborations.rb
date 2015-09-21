class AddInsularAssignmentToCollaborations < ActiveRecord::Migration
  def change
      add_column :collaborations, :for_island_cc, :boolean
  end
end
