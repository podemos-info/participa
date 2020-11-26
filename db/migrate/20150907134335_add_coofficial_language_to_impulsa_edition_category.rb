class AddCoofficialLanguageToImpulsaEditionCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_edition_categories, :coofficial_language, :string
  end
end
