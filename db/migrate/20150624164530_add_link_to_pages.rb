class AddLinkToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :link, :string
  end
end
