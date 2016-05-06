class AddDistrictToUser < ActiveRecord::Migration
  def change
    unless column_exists? :users, :district
      add_column :users, :district, :integer
    end
  end
end
