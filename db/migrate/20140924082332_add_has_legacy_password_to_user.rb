class AddHasLegacyPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_legacy_password, :boolean
  end
end
