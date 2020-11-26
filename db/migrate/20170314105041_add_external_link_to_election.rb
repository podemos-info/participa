class AddExternalLinkToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :external_link, :string
  end
end
