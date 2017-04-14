class CreateTableGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users do |t|
      t.references :group
      t.references :user
    end
  end
end
