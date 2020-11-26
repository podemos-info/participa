class AddDescriptionToImpulsaEdition < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_editions, :description, :text
  end
end
