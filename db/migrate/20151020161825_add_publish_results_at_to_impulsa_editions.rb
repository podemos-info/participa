class AddPublishResultsAtToImpulsaEditions < ActiveRecord::Migration
  def change
    add_column :impulsa_editions, :publish_results_at, :datetime
  end
end
