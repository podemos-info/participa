class AddMicrocreditOptionRefToMicrocreditLoans < ActiveRecord::Migration
  def change
    add_reference :microcredit_loans, :microcredit_option, foreign_key: true
  end
end
