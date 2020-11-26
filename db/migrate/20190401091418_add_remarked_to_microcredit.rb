class AddRemarkedToMicrocredit < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :remarked, :boolean, default: false
  end
end
