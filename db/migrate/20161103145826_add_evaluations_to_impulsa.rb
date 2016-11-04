class AddEvaluationsToImpulsa < ActiveRecord::Migration
  def change
    add_column :impulsa_edition_categories, :evaluation, :text
    add_column :impulsa_projects, :evaluator1_evaluation, :text
    add_column :impulsa_projects, :evaluator2_evaluation, :text
    add_column :impulsa_projects, :evaluation_result, :string
  end
end
