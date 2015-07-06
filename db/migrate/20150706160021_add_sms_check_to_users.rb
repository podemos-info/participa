class AddSmsCheckToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_check_at, :datetime
  end
end
