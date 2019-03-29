class AddTextButtonToPage < ActiveRecord::Migration
  def change
    add_column :pages, :text_button, :string
  end
end
