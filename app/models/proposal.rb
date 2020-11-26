require 'numeric'
class Proposal < ApplicationRecord
  has_many :supports, dependent: :destroy

  scope :reddit,  -> { where(reddit_threshold: true) }
  scope :recent,  -> { order('created_at desc') }
  scope :popular, -> { order('supports_count desc') }
  scope :time,    -> { order('created_at asc') }
  scope :hot,     -> { order('hotness desc') }
  
  before_save :update_threshold

  def update_threshold
    self.reddit_threshold = true if reddit_required_votes?
  end

  def support_percentage
    supports_count.percent_of(confirmed_users)
  end

  def confirmed_users
    User.confirmed.count
  end

  def remaining_endorsements_for_approval
    (monthly_email_required_votes - votes).to_i
  end

  def reddit_required_votes
    ((0.2).percent * confirmed_users).to_i
  end

  def monthly_email_required_votes
    (2.percent * confirmed_users).to_i
  end

  def agoravoting_required_votes
    (10.percent * confirmed_users).to_i
  end

  def reddit_required_votes?
    votes >= reddit_required_votes
  end

  def monthly_email_required_votes?
    supports_count >= monthly_email_required_votes
  end
  
  def agoravoting_required_votes?
    supports_count >= agoravoting_required_votes
  end

  def finished?
    finishes_at<Date.today
  end

  def discarded?
    finished? && !agoravoting_required_votes?
  end

  def finishes_at
    created_at + 3.months
  end

  def supported?(user)
    return false unless user
    user.supports.where(proposal: self).any?
  end

  def supportable? user
    not (finished? || discarded?(user))
  end

  def self.filter(filtering_params)
    results = self.reddit
    results = results.public_send(filtering_params) if filtering_params.present?
    results
  end

  def hotness
    supports_count + (days_since_created * 1000)
  end

  def days_since_created
    ((Time.now - created_at)/60/60/24).to_i
  end

  def supports_count
    supports.where("created_at<?", finishes_at).count
  end
end