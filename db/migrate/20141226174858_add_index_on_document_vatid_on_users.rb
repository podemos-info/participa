class AddIndexOnDocumentVatidOnUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :document_vatid
  end
end
