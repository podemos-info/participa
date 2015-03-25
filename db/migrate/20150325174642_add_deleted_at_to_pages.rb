class AddDeletedAtToPages < ActiveRecord::Migration
  def change
    add_column :pages, :deleted_at, :datetime
    add_index :pages, :deleted_at
  end
end
