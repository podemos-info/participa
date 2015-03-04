class ChangeQueryFromReports < ActiveRecord::Migration
  def change
    change_column :reports, :query, :text
  end
end
