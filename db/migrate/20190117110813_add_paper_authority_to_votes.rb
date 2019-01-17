class AddPaperAuthorityToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :paper_authority_id, :integer
  end
end
