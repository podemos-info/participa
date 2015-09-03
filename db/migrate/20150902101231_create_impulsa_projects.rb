class CreateImpulsaProjects < ActiveRecord::Migration
  def change
    create_table :impulsa_projects do |t|
      t.references :impulsa_edition_category, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :review_fields
      t.text :additional_contact
      t.text :counterpart_information
      t.string :name, null: false
      t.string :authority
      t.string :authority_name
      t.string :authority_phone
      t.string :authority_email
      t.string :organization_name
      t.text :organization_address
      t.string :organization_web
      t.string :organization_nif
      t.integer :organization_year
      t.string :organization_legal_name
      t.string :organization_legal_email
      t.text :organization_mission
      t.text :career
      t.string :counterpart
      t.text :territorial_context
      t.text :short_description
      t.text :long_description
      t.text :aim
      t.text :metodology
      t.text :population_segment
      t.string :video_link
      t.string :alternative_language
      t.string :alternative_name
      t.text :alternative_organization_mission
      t.text :alternative_territorial_context
      t.text :alternative_short_description
      t.text :alternative_long_description
      t.text :alternative_aim
      t.text :alternative_metodology
      t.text :alternative_population_segment

      t.timestamps null: false
    end
    add_attachment :impulsa_projects, :logo
    add_attachment :impulsa_projects, :endorsement
    add_attachment :impulsa_projects, :register_entry
    add_attachment :impulsa_projects, :statutes
    add_attachment :impulsa_projects, :responsible_nif
    add_attachment :impulsa_projects, :fiscal_obligations_certificate
    add_attachment :impulsa_projects, :labor_obligations_certificate
    add_attachment :impulsa_projects, :last_fiscal_year_report_of_activities
    add_attachment :impulsa_projects, :last_fiscal_year_annual_accounts
    add_attachment :impulsa_projects, :schedule
    add_attachment :impulsa_projects, :activities_resources
    add_attachment :impulsa_projects, :requested_budget
    add_attachment :impulsa_projects, :monitoring_evaluation
  end
end
