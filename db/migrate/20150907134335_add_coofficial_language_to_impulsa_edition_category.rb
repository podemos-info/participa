class AddCoofficialLanguageToImpulsaEditionCategory < ActiveRecord::Migration
  def change
    add_column :impulsa_edition_categories, :coofficial_language, :string
  end
end
