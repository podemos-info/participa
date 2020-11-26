class CreateCategoriesPosts < ActiveRecord::Migration[4.2]
  def change
    create_table :categories_posts do |t|
      t.references :post, index: true
      t.references :category, index: true
      t.timestamps
    end
  end
end
