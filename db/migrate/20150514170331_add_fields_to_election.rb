class AddFieldsToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :priority, :integer
    add_column :elections, :info_text, :string
  end
end
