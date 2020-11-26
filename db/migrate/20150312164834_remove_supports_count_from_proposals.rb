class RemoveSupportsCountFromProposals < ActiveRecord::Migration[4.2]
  def change
    remove_column :proposals, :supports_count
  end
end
