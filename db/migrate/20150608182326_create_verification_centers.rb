class CreateVerificationCenters < ActiveRecord::Migration
  def change
    create_table :verification_centers do |t|
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
