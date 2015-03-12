class AddSupportCountToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :supports_count, :integer, default: 0
  end
end
