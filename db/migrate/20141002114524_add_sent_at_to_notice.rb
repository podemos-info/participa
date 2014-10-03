class AddSentAtToNotice < ActiveRecord::Migration
  def change
    add_column :notices, :sent_at, :datetime
  end
end
