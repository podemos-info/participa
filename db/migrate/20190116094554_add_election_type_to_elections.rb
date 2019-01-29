class AddElectionTypeToElections < ActiveRecord::Migration
  def up
    add_column :elections, :election_type, :integer, default: 0, null: true

    execute "UPDATE elections set election_type = 0"
    execute "UPDATE elections set election_type = 1 where external_link IS NOT NULL AND external_link <> ''"

    change_column_null :elections, :election_type, false
  end

  def down
    remove_column :elections, :election_type
  end
end
