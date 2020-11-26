class AddCountedAtToMicrocreditLoan < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredit_loans, :counted_at, :datetime
  end
end
