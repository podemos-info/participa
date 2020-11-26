class CreateProposals < ActiveRecord::Migration[4.2]
  def change
    create_table :proposals do |t|
      t.string  :title
      t.text    :description
      t.integer :votes
      t.string  :reddit_url
      t.string  :reddit_id
      t.timestamps
    end
  end
end
