class AddGenderToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :gender, :string
  end
end
