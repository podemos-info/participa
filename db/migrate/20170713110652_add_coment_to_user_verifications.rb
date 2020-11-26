class AddComentToUserVerifications < ActiveRecord::Migration[4.2]
  def change
    add_column :user_verifications, :comment, :text
  end
end
