class AddReturnToMicrocreditLoans < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :returned_at, :datetime
    add_reference :microcredit_loans, :transferred_to, references: :microcredit_loans
    add_attachment :microcredits, :renewal_terms
  end
end
