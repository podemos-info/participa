class AddSupportsCountToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :supports_count, :integer, default: 0
  end
end
