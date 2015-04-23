class AddDiscardedAtToMicrocreditLoans < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :discarded_at, :datetime
  end
end
