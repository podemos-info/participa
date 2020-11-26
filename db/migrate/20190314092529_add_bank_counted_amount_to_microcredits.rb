class AddBankCountedAmountToMicrocredits < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :bank_counted_amount, :integer, default: 0
  end
end
