class AddExternalLinkToElection < ActiveRecord::Migration
  def change
    add_column :elections, :external_link, :string
  end
end
