class AddPriorityToMicrocredit < ActiveRecord::Migration
  def change
    add_column :microcredits, :priority, :integer, default: 0
  end
end
