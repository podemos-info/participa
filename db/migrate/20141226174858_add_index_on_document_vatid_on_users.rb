class AddIndexOnDocumentVatidOnUsers < ActiveRecord::Migration
  def change
    add_index :users, :document_vatid
  end
end
