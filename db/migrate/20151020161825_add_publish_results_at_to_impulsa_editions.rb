class AddPublishResultsAtToImpulsaEditions < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_editions, :publish_results_at, :datetime
  end
end
