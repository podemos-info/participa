class AddCircleToUser < ActiveRecord::Migration
  def change
    add_column :users, :circle, :string
  end
end
