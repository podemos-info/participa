class AddTextButtonToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :text_button, :string
  end
end
