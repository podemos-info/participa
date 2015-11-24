class CreateImpulsaEditions < ActiveRecord::Migration
  def change
    create_table :impulsa_editions do |t|
      t.string :name, null: false
      t.date :start_at
      t.date :new_projects_until
      t.date :review_projects_until
      t.date :validation_projects_until
      t.date :ends_at

      t.timestamps null: false
    end

    add_attachment :impulsa_editions, :legal
    add_attachment :impulsa_editions, :schedule_model
    add_attachment :impulsa_editions, :activities_resources_model
    add_attachment :impulsa_editions, :requested_budget_model
    add_attachment :impulsa_editions, :monitoring_evaluation_model
  end
end
