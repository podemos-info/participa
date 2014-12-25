class AddAgoraVersionToElectionLocation < ActiveRecord::Migration
  def change
    add_column :election_locations, :agora_version, :integer
  end
end
