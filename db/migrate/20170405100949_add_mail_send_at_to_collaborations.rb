class AddMailSendAtToCollaborations < ActiveRecord::Migration
  def change
    add_column :collaborations, :mail_send_at, :date
  end
end
