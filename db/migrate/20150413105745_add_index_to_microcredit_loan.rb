class AddIndexToMicrocreditLoan < ActiveRecord::Migration[4.2]
  def change
    add_index MicrocreditLoan, [:microcredit_id]
  end
end
