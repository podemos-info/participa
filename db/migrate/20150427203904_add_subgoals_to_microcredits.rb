class AddSubgoalsToMicrocredits < ActiveRecord::Migration
  def change
    add_column :microcredits, :subgoals, :text
  end
end
