class AddCounterKeyToElection < ActiveRecord::Migration
  def change
    add_column :elections, :counter_key, :string
  end
end
