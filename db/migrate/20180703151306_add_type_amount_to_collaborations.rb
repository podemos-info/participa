class AddTypeAmountToCollaborations < ActiveRecord::Migration
  def change
    add_column :collaborations, :type_amount, :integer
  end
end
