class AddBornAtToUserVerifications < ActiveRecord::Migration
  def change
    add_column :user_verifications, :born_at, :date
  end
end
