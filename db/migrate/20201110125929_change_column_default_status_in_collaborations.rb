class ChangeColumnDefaultStatusInCollaborations < ActiveRecord::Migration
  def change
    change_column_default(:collaborations,:status,2)
  end
end
