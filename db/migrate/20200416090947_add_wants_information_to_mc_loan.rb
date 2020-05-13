class AddWantsInformationToMcLoan < ActiveRecord::Migration
  def change
    add_column :microcredit_loans, :wants_information_by_email, :boolean, default: true
  end
end
