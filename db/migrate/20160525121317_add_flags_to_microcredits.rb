class AddFlagsToMicrocredits < ActiveRecord::Migration
  def change
    add_column :microcredits, :flags, :integer, { default: 0 }
  end
end
