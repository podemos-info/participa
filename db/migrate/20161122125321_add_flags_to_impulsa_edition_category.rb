class AddFlagsToImpulsaEditionCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_edition_categories, :flags, :integer
  end
end
