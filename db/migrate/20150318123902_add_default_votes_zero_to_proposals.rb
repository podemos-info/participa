class AddDefaultVotesZeroToProposals < ActiveRecord::Migration
  def change
    change_column :proposals, :votes, :integer, default: 0
  end
end
