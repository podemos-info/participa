class AddFieldsToMicrocreditLoans < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredit_loans, :iban_account, :string
    add_column :microcredit_loans, :iban_bic, :string
  end
end
