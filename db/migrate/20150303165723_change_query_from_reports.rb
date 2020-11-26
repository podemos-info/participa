class ChangeQueryFromReports < ActiveRecord::Migration[4.2]
  def change
    change_column :reports, :query, :text
  end
end
