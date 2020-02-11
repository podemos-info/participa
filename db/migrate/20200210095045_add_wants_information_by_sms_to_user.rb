class AddWantsInformationBySmsToUser < ActiveRecord::Migration
  def change
    add_column :users, :wants_information_by_sms, :boolean, default: true
  end
end
