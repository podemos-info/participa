class AddMediaUrlToPost < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :media_url, :string
  end
end
