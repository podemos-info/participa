class AddMissingFieldsToImpulsaProject < ActiveRecord::Migration
  def change
    add_column :impulsa_projects, :total_budget, :integer
    add_column :impulsa_projects, :coofficial_territorial_context, :text
    add_column :impulsa_projects, :coofficial_long_description, :text
    add_column :impulsa_projects, :coofficial_aim, :text
    add_column :impulsa_projects, :coofficial_metodology, :text
    add_column :impulsa_projects, :coofficial_population_segment, :text
    add_column :impulsa_projects, :coofficial_organization_mission, :text
    add_column :impulsa_projects, :coofficial_career, :text
  end
end
