class AddCountedAtToMicrocreditLoan < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :counted_at, :datetime
  end
end
