class AlterImpulsaAttachments < ActiveRecord::Migration
  def change
    remove_attachment :impulsa_editions, :legal
    add_column :impulsa_editions, :legal, :text
    add_attachment :impulsa_edition_categories, :schedule_model_override
    add_attachment :impulsa_edition_categories, :activities_resources_model_override
    add_attachment :impulsa_edition_categories, :requested_budget_model_override
    add_attachment :impulsa_edition_categories, :monitoring_evaluation_model_override
  end
end
