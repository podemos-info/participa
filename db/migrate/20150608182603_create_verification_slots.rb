class CreateVerificationSlots < ActiveRecord::Migration
  def change
    create_table :verification_slots do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :verification_center_id

      t.timestamps
    end
  end
end
