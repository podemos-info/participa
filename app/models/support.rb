class Support < ActiveRecord::Base
  belongs_to :user
  belongs_to :proposal, counter_cache: true

  after_save :update_hotness

  def update_hotness
    proposal.update_attribute(:hotness, proposal.hotness)
  end
end
