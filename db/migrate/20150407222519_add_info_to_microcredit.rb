class AddInfoToMicrocredit < ActiveRecord::Migration
  def change
    add_column :microcredits, :agreement_link, :string
    add_column :microcredits, :contact_phone, :string
    add_column :microcredits, :total_goal, :integer
  end
end
