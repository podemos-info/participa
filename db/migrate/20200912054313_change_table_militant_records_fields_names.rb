class ChangeTableMilitantRecordsFieldsNames < ActiveRecord::Migration
  def change
    remove_column :militant_records, :circle_name, :string
    add_column :militant_records, :vote_circle_name, :string
    remove_column :militant_records, :begin_in_circle, :datetime
    add_column :militant_records, :begin_in_vote_circle, :datetime
    remove_column :militant_records, :end_in_circle, :datetime
    add_column :militant_records, :end_in_vote_circle, :datetime
  end
end
