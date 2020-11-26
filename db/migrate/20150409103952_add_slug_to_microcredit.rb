class AddSlugToMicrocredit < ActiveRecord::Migration[4.2]
  def change
    add_column :microcredits, :slug, :string
    add_index :microcredits, :slug, unique: true
    Microcredit.find_each(&:save)
  end
end
