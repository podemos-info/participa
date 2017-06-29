class CreateUserVerifications < ActiveRecord::Migration
  def change
    create_table :user_verifications do |t|
      t.references :user, null: false
      t.references :author_id,foreign_key:{to_table: :users}
      t.datetime :processed_at
      t.boolean :result

      t.timestamps null: false
    end

    add_attachment :user_verifications, :front_vatid
    add_attachment :user_verifications, :back_vatid
  end
end