class AddDocumentCopyFrontAndBackToUser < ActiveRecord::Migration
  def change
    rename_column :users, :document_copy_file_name, :document_copy_front_file_name
    rename_column :users, :document_copy_content_type, :document_copy_front_content_type
    rename_column :users, :document_copy_file_size, :document_copy_front_file_size
    rename_column :users, :document_copy_updated_at, :document_copy_front_updated_at
    add_attachment :users, :document_copy_back
  end
end
