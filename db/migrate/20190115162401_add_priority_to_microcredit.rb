class AddPriorityToMicrocredit < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :priority, :integer, default: 0
  end
end
