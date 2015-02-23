class AddNonUserInfoToCollaborations < ActiveRecord::Migration
  def change
    add_column :collaborations, :non_user_document_vatid, :string
    add_column :collaborations, :non_user_email, :string
    add_column :collaborations, :non_user_data, :text
    add_index :collaborations, :non_user_document_vatid
    add_index :collaborations, :non_user_email
  end
end
