class AddDiscardedAtToMicrocreditLoans < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredit_loans, :discarded_at, :datetime
  end
end
