class AddFieldsToCollaboration < ActiveRecord::Migration
  def change
    add_column :collaborations, :payment_type, :integer
    add_column :collaborations, :ccc_entity, :integer
    add_column :collaborations, :ccc_office, :integer
    add_column :collaborations, :ccc_dc, :integer
    add_column :collaborations, :ccc_account, :integer
    add_column :collaborations, :iban_account, :string
    add_column :collaborations, :iban_bic, :string
  end
end
