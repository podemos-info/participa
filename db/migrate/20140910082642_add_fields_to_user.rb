class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :born_at, :date
    add_column :users, :wants_newsletter, :boolean
    add_column :users, :document_type, :integer
    add_column :users, :document_vatid, :string
  end
end
