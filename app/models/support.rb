class Support < ActiveRecord::Base
  belongs_to :user
  belongs_to :proposal, counter_cache: true
end
