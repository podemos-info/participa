class AddMetaFieldsToModels < ActiveRecord::Migration
  def change
    add_column :elections, :meta_description, :string
    add_column :elections, :meta_image, :string
    add_column :pages, :meta_description, :string
    add_column :pages, :meta_image, :string
  end
end
