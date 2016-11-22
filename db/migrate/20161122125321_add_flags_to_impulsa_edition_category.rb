class AddFlagsToImpulsaEditionCategory < ActiveRecord::Migration
  def change
    add_column :impulsa_edition_categories, :flags, :integer
  end
end
