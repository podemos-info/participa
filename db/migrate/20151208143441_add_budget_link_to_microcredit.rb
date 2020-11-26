class AddBudgetLinkToMicrocredit < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :budget_link, :string
  end
end
