class AddAuthorToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :author, :string
  end
end
