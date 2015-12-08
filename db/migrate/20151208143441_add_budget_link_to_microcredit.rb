class AddBudgetLinkToMicrocredit < ActiveRecord::Migration
  def change
    add_column :microcredits, :budget_link, :string
  end
end
