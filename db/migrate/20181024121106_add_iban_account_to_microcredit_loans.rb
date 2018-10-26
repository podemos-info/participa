class AddIbanAccountToMicrocreditLoans < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :iban_account, :string
  end
end
