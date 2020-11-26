class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.string :title
      t.string :query
      t.text :main_group
      t.text :groups
      t.text :results

      t.timestamps
    end
  end
end
