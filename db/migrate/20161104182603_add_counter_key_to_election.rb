class AddCounterKeyToElection < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :counter_key, :string
  end
end
