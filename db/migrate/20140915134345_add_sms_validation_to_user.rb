class AddSmsValidationToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string
    add_column :users, :sms_confirmation_token, :string
    add_column :users, :confirmation_sms_sent_at, :datetime
    add_column :users, :sms_confirmed_at, :datetime
    add_index :users, :sms_confirmation_token, :unique => true # for sms_activable
  end
end
