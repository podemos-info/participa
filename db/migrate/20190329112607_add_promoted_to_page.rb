class AddPromotedToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :promoted, :boolean, default: false
  end
end
