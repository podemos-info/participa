class AddBankCountedAmountToMicrocredits < ActiveRecord::Migration
  def change
    add_column :microcredits, :bank_counted_amount, :integer, default: 0
  end
end
