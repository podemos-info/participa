class AddVotesToImpulsaProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :impulsa_projects, :votes, :integer, default: 0
  end
end
