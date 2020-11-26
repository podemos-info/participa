class AddVersionDateToReport < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :version_at, :datetime
  end
end
