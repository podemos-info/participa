class AddAddressFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :address, :string
    add_column :users, :town, :string
    add_column :users, :province, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
  end
end
