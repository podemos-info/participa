class AddRemarkedToMicrocredit < ActiveRecord::Migration
  def change
    add_column :microcredits, :remarked, :boolean, default: false
  end
end
