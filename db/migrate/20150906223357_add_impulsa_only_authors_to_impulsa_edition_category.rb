class AddImpulsaOnlyAuthorsToImpulsaEditionCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_edition_categories, :only_authors, :boolean
  end
end
