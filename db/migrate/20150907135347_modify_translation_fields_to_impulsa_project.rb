class ModifyTranslationFieldsToImpulsaProject < ActiveRecord::Migration
  def change
    add_column :impulsa_projects, :coofficial_translation, :boolean
    add_column :impulsa_projects, :coofficial_name, :string
    add_column :impulsa_projects, :coofficial_short_description, :text
    add_column :impulsa_projects, :coofficial_video_link, :string
    remove_column :impulsa_projects, :alternative_language, :string
    remove_column :impulsa_projects, :alternative_name, :string
    remove_column :impulsa_projects, :alternative_career, :text
    remove_column :impulsa_projects, :alternative_short_description, :text
    remove_column :impulsa_projects, :alternative_long_description, :text
    remove_column :impulsa_projects, :alternative_organization_mission, :text
    remove_column :impulsa_projects, :alternative_territorial_context, :text
    remove_column :impulsa_projects, :alternative_aim, :text
    remove_column :impulsa_projects, :alternative_metodology, :text
    remove_column :impulsa_projects, :alternative_population_segment, :text
  end
end