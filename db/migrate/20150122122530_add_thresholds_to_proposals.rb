class AddThresholdsToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :reddit_threshold, :boolean, default: false
  end
end
