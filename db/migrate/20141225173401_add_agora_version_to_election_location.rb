class AddAgoraVersionToElectionLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :election_locations, :agora_version, :integer
  end
end
