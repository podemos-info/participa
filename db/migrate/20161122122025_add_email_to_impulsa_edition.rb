class AddEmailToImpulsaEdition < ActiveRecord::Migration
  def change
    add_column :impulsa_editions, :email, :string
  end
end
