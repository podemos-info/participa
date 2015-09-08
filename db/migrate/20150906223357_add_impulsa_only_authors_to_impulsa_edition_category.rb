class AddImpulsaOnlyAuthorsToImpulsaEditionCategory < ActiveRecord::Migration
  def change
    add_column :impulsa_edition_categories, :only_authors, :boolean
  end
end
