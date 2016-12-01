class AddAttachmentColumnsToUsers < ActiveRecord::Migration
  def change
    add_attachment :users, :document_copy
  end
end
