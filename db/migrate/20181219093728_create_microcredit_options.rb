class CreateMicrocreditOptions < ActiveRecord::Migration
  def change
    create_table :microcredit_options do |t|
      t.belongs_to :microcredit, index: true
      t.string :name
      t.integer :parent_id
    end

    add_reference :microcredit_loans, :microcredit_option, foreign_key: true
  end
end
