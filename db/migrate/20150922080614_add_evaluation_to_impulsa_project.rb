class AddEvaluationToImpulsaProject < ActiveRecord::Migration
  def change
    add_reference :impulsa_projects, :evaluator1, index: true, foreign_key: true, references: :users
    add_column :impulsa_projects, :evaluator1_invalid_reasons, :text
    add_attachment :impulsa_projects, :evaluator1_analysis
    add_reference :impulsa_projects, :evaluator2, index: true, foreign_key: true, references: :users
    add_column :impulsa_projects, :evaluator2_invalid_reasons, :text
    add_attachment :impulsa_projects, :evaluator2_analysis
  end
end
