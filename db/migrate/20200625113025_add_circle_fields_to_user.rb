class AddCircleFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :circle_original_code, :string
    add_column :users, :circle_changed_at, :datetime
  end
end
