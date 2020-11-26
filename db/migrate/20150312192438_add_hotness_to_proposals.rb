class AddHotnessToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :hotness, :integer, default: 0
  end
end
