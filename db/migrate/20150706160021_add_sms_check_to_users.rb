class AddSmsCheckToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :sms_check_at, :datetime
  end
end
