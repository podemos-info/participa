class AddImageUrlToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :image_url, :string
  end
end
