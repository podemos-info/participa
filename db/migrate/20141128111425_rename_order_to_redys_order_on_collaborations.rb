class RenameOrderToRedysOrderOnCollaborations < ActiveRecord::Migration[4.2]
  def change
    rename_column :collaborations, :order, :redsys_order
  end
end
