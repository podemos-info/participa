class RenameOrderToRedysOrderOnCollaborations < ActiveRecord::Migration
  def change
    rename_column :collaborations, :order, :redsys_order
  end
end
