class AddPromotedToPage < ActiveRecord::Migration
  def change
    add_column :pages, :promoted, :boolean, default: false
  end
end
