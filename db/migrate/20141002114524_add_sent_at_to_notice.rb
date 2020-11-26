class AddSentAtToNotice < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :sent_at, :datetime
  end
end
