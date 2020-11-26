class AddThresholdsToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :reddit_threshold, :boolean, default: false
  end
end
