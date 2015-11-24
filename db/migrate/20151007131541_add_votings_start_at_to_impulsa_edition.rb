class AddVotingsStartAtToImpulsaEdition < ActiveRecord::Migration
  def change
    add_column :impulsa_editions, :votings_start_at, :datetime
  end
end
