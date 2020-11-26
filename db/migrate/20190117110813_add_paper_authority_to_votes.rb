class AddPaperAuthorityToVotes < ActiveRecord::Migration[4.2]
  def change
    add_column :votes, :paper_authority_id, :integer
  end
end
