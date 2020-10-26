class VoteCircle < ActiveRecord::Base

  ransacker :vote_circle_province_id, formatter: proc { |value|
    VoteCircle.where("code like ?", value).map { |vote_circle| vote_circle.code }.uniq
  } do |parent|
    parent.table[:code]
  end

  ransacker :vote_circle_autonomy_id, formatter: proc { |value|
    VoteCircle.where("code like ?", value).map { |vote_circle| vote_circle.code }.uniq
  } do |parent|
    parent.table[:code]
  end

  def is_active?
    self.code.present?
  end
end
