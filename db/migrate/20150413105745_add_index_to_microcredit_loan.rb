class AddIndexToMicrocreditLoan < ActiveRecord::Migration
  def change
    add_index MicrocreditLoan, [:microcredit_id]
  end
end
