class AddNewAgoraVersionToElectionLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :election_locations, :new_agora_version, :integer
  end
end
