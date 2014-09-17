class Notice < ActiveRecord::Base
  validates :title, :body, presence: true
end
