class VoteCircle < ActiveRecord::Base
  def is_active?
    self.code.present?
  end
end
