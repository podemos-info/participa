class AddWantsCardToUserVerifications < ActiveRecord::Migration[4.2]
  def change
    add_column :user_verifications, :wants_card, :boolean
  end
end
