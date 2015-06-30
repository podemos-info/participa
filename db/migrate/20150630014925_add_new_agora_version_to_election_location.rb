class AddNewAgoraVersionToElectionLocation < ActiveRecord::Migration
  def change
    add_column :election_locations, :new_agora_version, :integer
  end
end
