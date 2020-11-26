class AddHasLegacyPasswordToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :has_legacy_password, :boolean
  end
end
