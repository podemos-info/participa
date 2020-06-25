class CreateCircles < ActiveRecord::Migration
  def change
    create_table :circles do |t|
      t.string :original_name
      t.string :original_code
      t.timestamps null: false
    end
  end
end
