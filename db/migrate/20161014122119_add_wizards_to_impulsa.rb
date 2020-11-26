class AddWizardsToImpulsa < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_edition_categories, :wizard, :text
    add_column :impulsa_projects, :wizard_values, :text
    add_column :impulsa_projects, :state, :string
    add_column :impulsa_projects, :wizard_step, :string
  end
end
