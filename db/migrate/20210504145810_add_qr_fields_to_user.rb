class AddQrFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :qr_hash, :string
    add_column :users, :qr_secret, :string
    add_column :users, :qr_created_at, :datetime
  end
end
