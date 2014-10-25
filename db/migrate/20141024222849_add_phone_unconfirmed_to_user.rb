class AddPhoneUnconfirmedToUser < ActiveRecord::Migration
  def change
    add_column :users, :unconfirmed_phone, :string
  end
end
