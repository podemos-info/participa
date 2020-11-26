class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.string :title
      t.integer :id_form
      t.string :slug
      t.boolean :require_login

      t.timestamps
    end
  end
end
