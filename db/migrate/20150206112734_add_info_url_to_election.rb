class AddInfoUrlToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :info_url, :string
  end
end
