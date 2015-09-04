class CreateImpulsaProjectTopics < ActiveRecord::Migration
  def change
    create_table :impulsa_project_topics do |t|
      t.references :impulsa_project, index: true, foreign_key: true
      t.references :impulsa_edition_topic, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
