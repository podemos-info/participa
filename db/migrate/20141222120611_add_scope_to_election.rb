class AddScopeToElection < ActiveRecord::Migration
  def change
    add_column :elections, :scope, :int
  end
end
