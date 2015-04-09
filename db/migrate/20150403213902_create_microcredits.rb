class CreateMicrocredits < ActiveRecord::Migration
  def change
    create_table :microcredits do |t|
      t.string :title
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :reset_at
      t.text :limits
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
