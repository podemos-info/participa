class AddFieldsToMicrocreditLoans < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :iban_account, :string
    add_column :microcredit_loans, :iban_bic, :string
  end
end
