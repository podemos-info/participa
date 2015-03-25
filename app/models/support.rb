class Support < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :proposal, dependent: :destroy, counter_cache: true

  after_save :update_hotness

  def update_hotness
    proposal.update_attribute(:hotness, proposal.hotness)
  end
end
