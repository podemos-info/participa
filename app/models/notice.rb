class Notice < ActiveRecord::Base
  validates :title, :body, presence: true

  default_scope { order('created_at DESC') }

  paginates_per 5
end
