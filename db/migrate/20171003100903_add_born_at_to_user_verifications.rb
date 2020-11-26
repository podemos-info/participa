class AddBornAtToUserVerifications < ActiveRecord::Migration[4.2]
  def change
    add_column :user_verifications, :born_at, :date
  end
end
