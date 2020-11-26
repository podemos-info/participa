class AddWizardReviewToImpulsaProject < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_projects, :wizard_review, :text
  end
end
