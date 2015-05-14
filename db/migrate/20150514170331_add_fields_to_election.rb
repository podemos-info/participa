class AddFieldsToElection < ActiveRecord::Migration
  def change
    add_column :elections, :priority, :integer
    add_column :elections, :info_text, :string
  end
end
