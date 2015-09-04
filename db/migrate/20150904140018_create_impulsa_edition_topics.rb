class CreateImpulsaEditionTopics < ActiveRecord::Migration
  def change
    create_table :impulsa_edition_topics do |t|
      t.references :impulsa_edition, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
