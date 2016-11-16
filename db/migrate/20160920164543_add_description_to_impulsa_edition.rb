class AddDescriptionToImpulsaEdition < ActiveRecord::Migration
  def change
    add_column :impulsa_editions, :description, :text
  end
end
