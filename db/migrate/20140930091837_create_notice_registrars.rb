class CreateNoticeRegistrars < ActiveRecord::Migration
  def change
    create_table :notice_registrars do |t|
      t.string :registration_id
      t.boolean :status

      t.timestamps
    end
  end
end
