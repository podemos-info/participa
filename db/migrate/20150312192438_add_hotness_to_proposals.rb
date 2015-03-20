class AddHotnessToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :hotness, :integer, default: 0
  end
end
