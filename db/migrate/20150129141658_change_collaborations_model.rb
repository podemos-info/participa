class ChangeCollaborationsModel < ActiveRecord::Migration
  def change
    # redsys payment data moved to orders
    remove_column :collaborations, :redsys_order, :string
    remove_column :collaborations, :redsys_response_recieved_at, :datetime
    remove_column :collaborations, :redsys_response_code, :string
    remove_column :collaborations, :response_status, :string
    remove_column :collaborations, :redsys_response, :text

    # collaboration status
    add_column    :collaborations, :status, :integer, { default: 0 }

    # only saves relevant redsys information for collaboration
    add_column    :collaborations, :redsys_identifier, :string
    add_column    :collaborations, :redsys_expiration, :datetime

    # generic parent for orders
    remove_column :orders, :collaboration_id, :integer
    add_column    :orders, :user_id, :integer
    add_column    :orders, :parent_id, :integer
    add_column    :orders, :parent_type, :string

    # payment description, amount and first payment mark
    add_column    :orders, :reference, :string
    add_column    :orders, :amount, :integer
    add_column    :orders, :first, :boolean

    # every payment type has orders now
    add_column    :orders, :payment_type, :integer
    add_column    :orders, :payment_identifier, :string
    add_column    :orders, :payment_response, :text
  end
end


