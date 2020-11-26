class AddEvaluationToImpulsaProject < ActiveRecord::Migration[4.2]
  def change
    add_reference :impulsa_projects, :evaluator1, references: :users
    add_column :impulsa_projects, :evaluator1_invalid_reasons, :text
    add_attachment :impulsa_projects, :evaluator1_analysis
    add_reference :impulsa_projects, :evaluator2, references: :users
    add_column :impulsa_projects, :evaluator2_invalid_reasons, :text
    add_attachment :impulsa_projects, :evaluator2_analysis
  end
end
