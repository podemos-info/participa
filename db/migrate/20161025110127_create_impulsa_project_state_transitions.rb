class CreateImpulsaProjectStateTransitions < ActiveRecord::Migration
  def change
    create_table :impulsa_project_state_transitions do |t|
      t.references :impulsa_project, index: true, foreign_key: true
      t.string :namespace
      t.string :event
      t.string :from
      t.string :to
      t.timestamp :created_at
    end
  end
end
