class ChangeProposalTitleToTypeText < ActiveRecord::Migration
  def change
    change_column :proposals, :title,  :text, limit: nil
  end
end
