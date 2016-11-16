class AddWizardReviewToImpulsaProject < ActiveRecord::Migration
  def change
    add_column :impulsa_projects, :wizard_review, :text
  end
end
