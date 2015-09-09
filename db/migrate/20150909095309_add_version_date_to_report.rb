class AddVersionDateToReport < ActiveRecord::Migration
  def change
    add_column :reports, :version_at, :datetime
  end
end
