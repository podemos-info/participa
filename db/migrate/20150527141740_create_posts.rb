class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :slug
      t.integer :status
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
