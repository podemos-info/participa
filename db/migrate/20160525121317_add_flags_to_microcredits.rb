class AddFlagsToMicrocredits < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :flags, :integer, { default: 0 }
  end
end
