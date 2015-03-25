class AddInfoUrlToElection < ActiveRecord::Migration
  def change
    add_column :elections, :info_url, :string
  end
end
