class AddAccountNumberToMicrocredit < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :account_number, :string
  end
end
