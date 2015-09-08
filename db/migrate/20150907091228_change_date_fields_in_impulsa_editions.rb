class ChangeDateFieldsInImpulsaEditions < ActiveRecord::Migration
  def self.up
    change_column :impulsa_editions, :start_at, :datetime
    change_column :impulsa_editions, :new_projects_until, :datetime
    change_column :impulsa_editions, :review_projects_until, :datetime
    change_column :impulsa_editions, :validation_projects_until, :datetime
    change_column :impulsa_editions, :ends_at, :datetime
  end
  def self.down
    change_column :impulsa_editions, :start_at, :date
    change_column :impulsa_editions, :new_projects_until, :date
    change_column :impulsa_editions, :review_projects_until, :date
    change_column :impulsa_editions, :validation_projects_until, :date
    change_column :impulsa_editions, :ends_at, :date
  end
end
