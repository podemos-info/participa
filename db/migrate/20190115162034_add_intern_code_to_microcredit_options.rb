class AddInternCodeToMicrocreditOptions < ActiveRecord::Migration
  def change
    add_column :microcredit_options, :intern_code, :string
  end
end
