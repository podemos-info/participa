class AddVotesToImpulsaProjects < ActiveRecord::Migration
  def change
    add_column :impulsa_projects, :votes, :integer, default: 0
  end
end
