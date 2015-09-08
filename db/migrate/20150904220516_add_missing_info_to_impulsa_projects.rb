class AddMissingInfoToImpulsaProjects < ActiveRecord::Migration
  def change
    add_column :impulsa_projects, :organization_type, :integer
    add_column :impulsa_projects, :alternative_career, :text
    add_attachment :impulsa_projects, :scanned_nif
    add_attachment :impulsa_projects, :home_certificate
    add_attachment :impulsa_projects, :bank_certificate
  end
end
