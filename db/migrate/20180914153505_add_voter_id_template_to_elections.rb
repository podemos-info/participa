class AddVoterIdTemplateToElections < ActiveRecord::Migration
  def change
    add_column :elections, :voter_id_template, :string
  end
end
