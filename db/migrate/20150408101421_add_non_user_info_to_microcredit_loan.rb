class AddNonUserInfoToMicrocreditLoan < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :ip, :string
    add_column :microcredit_loans, :document_vatid, :string
  end
end
