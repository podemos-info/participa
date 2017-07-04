class AddWantsCardToUserVerifications < ActiveRecord::Migration
  def change
    add_column :user_verifications, :wants_card, :boolean
  end
end
