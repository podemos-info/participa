class AddVotingsStartAtToImpulsaEdition < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_editions, :votings_start_at, :datetime
  end
end
