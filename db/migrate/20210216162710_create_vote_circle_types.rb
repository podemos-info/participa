class CreateVoteCircleTypes < ActiveRecord::Migration
  def change
    create_table :vote_circle_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
