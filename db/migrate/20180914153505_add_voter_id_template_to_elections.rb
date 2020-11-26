class AddVoterIdTemplateToElections < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :voter_id_template, :string
  end
end
