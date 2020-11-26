class AddInternCodeToMicrocreditOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredit_options, :intern_code, :string
  end
end
