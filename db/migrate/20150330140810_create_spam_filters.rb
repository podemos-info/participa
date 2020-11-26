class CreateSpamFilters < ActiveRecord::Migration[4.2]
  def change
    create_table :spam_filters do |t|
      t.string :name
      t.text :code
      t.text :data
      t.string :query
      t.boolean :active

      t.timestamps
    end
  end
end
