class AddNonUserInfoToMicrocreditLoan < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :ip, :string
    add_column :microcredit_loans, :document_vatid, :string
    add_index :microcredit_loans, :document_vatid
    add_index :microcredit_loans, :ip
  end
end
