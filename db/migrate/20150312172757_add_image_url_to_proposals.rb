class AddImageUrlToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :image_url, :string
  end
end
