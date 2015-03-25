class RemoveSupportsCountFromProposals < ActiveRecord::Migration
  def change
    remove_column :proposals, :supports_count
  end
end
