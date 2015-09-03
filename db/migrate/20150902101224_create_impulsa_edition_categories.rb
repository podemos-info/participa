class CreateImpulsaEditionCategories < ActiveRecord::Migration
  def change
    create_table :impulsa_edition_categories do |t|
      t.references :impulsa_edition, index: true, foreign_key: true
      t.string :name, null: false
      t.integer :category_type, null: false
      t.integer :winners
      t.integer :prize
      t.string :territories

      t.timestamps null: false
    end
  end
end
