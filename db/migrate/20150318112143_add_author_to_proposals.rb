class AddAuthorToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :author, :string
  end
end
