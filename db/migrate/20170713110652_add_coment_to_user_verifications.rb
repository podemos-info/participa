class AddComentToUserVerifications < ActiveRecord::Migration
  def change
    add_column :user_verifications, :comment, :text
  end
end
