class ChangeProposalTitleToTypeText < ActiveRecord::Migration[4.2]
  def change
    change_column :proposals, :title,  :text, limit: nil
  end
end
