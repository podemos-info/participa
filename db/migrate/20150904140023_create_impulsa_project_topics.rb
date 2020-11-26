class CreateImpulsaProjectTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :impulsa_project_topics do |t|
      t.references :impulsa_project, index: true, foreign_key: true
      t.references :impulsa_edition_topic, index: true, foreign_key: true
    end
  end
end
