class AddVotingInfoToElectionLocation < ActiveRecord::Migration
  def change
    add_column :election_locations, :title, :text
    add_column :election_locations, :layout, :string
    add_column :election_locations, :description, :text
    add_column :election_locations, :share_text, :string
    add_column :election_locations, :theme, :string
  end
end
