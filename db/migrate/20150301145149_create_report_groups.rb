class CreateReportGroups < ActiveRecord::Migration
  def change
    create_table :report_groups do |t|
      t.string :title
      t.text :proc
      t.integer :width
      t.string :label
      t.string :data_label
      t.text :whitelist
      t.text :blacklist
      t.integer :minimum
      t.string :minimum_label
      t.string :visualization

      t.timestamps
    end
  end
end