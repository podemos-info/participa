class RenameUserCircleColumnName < ActiveRecord::Migration
  def change
    rename_column :users, :circle, :old_circle_data
  end
end
