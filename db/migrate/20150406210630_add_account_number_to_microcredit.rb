class AddAccountNumberToMicrocredit < ActiveRecord::Migration
  def change
    add_column :microcredits, :account_number, :string
  end
end
