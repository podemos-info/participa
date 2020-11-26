class AddEmailToImpulsaEdition < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_editions, :email, :string
  end
end
