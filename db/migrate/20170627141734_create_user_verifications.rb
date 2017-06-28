class CreateUserVerifications < ActiveRecord::Migration
  def change
    create_table :user_verifications do |t|
      t.integer :user_id
      t.integer :author_id
      t.datetime :processed_at
      t.boolean :result

      t.timestamps null: false
    end
  end
end