class AddDefaultVotesZeroToProposals < ActiveRecord::Migration[4.2]
  def change
    change_column :proposals, :votes, :integer, default: 0
  end
end
