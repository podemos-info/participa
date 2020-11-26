class AddMailSendAtToCollaborations < ActiveRecord::Migration[4.2]
  def change
    add_column :collaborations, :mail_send_at, :date
  end
end
