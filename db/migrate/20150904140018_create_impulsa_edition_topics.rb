class CreateImpulsaEditionTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :impulsa_edition_topics do |t|
      t.references :impulsa_edition, index: true, foreign_key: true
      t.string :name
    end
  end
end
