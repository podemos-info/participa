class AddCircleToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :circle, :string
  end
end
