class CreateNotices < ActiveRecord::Migration[4.2]
  def change
    create_table :notices do |t|
      t.string :title
      t.text :body
      t.string :link
      t.datetime :final_valid_at

      t.timestamps
    end
  end
end
