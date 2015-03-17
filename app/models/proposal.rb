require 'numeric'
class Proposal < ActiveRecord::Base
  has_many :supports

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
    supports.count.percent_of(confirmed_users)
  end

  #For testing purpose, temporarily using 300,000 as the number of confirmed users in the Census
  def confirmed_users
    300000
  end

  #For testing purpose, temporarily using 0 as the number of endorsements
  def remaining_endorsements_for_approval
    (monthly_email_required_votes - 0).to_i
  end

  #Assuming a Census of 300,000 registered users,
  #approximately 600 votes are required,
  #to achieve a 0.2% acceptance,
  #and thus move the proposal from Plaza Podemos to participa.podemos.info
  def reddit_required_votes
    ((0.2).percent * confirmed_users).to_i
  end

  #Assuming a Census of 300,000 registered users,
  #approximately 6000 votes are required,
  #to achieve a 2% acceptance,
  #and thus send an email to all members of the Census in participa.podemos.info informing them about the proposal
  def monthly_email_required_votes
    (2.percent * confirmed_users).to_i
  end

  #Assuming a Census of 300,000 registered users,
  #approximately 30,000 votes are required,
  #to achieve a 10% acceptance,
  #and thus move the proposal from participa.podemos.info to AgoraVoting
  def agoravoting_required_votes
    (10.percent * confirmed_users).to_i
  end

  # Set status in DB once threshold reached (just in case census increases)
  def reddit_required_votes?
    votes >= reddit_required_votes
  end

  # Set status in DB once threshold reached (just in case census increases)
  def agoravoting_required_votes?
    votes >= agoravoting_required_votes
  end

  def finishes_at
    created_at + 3.months
  end

  def supported?(user)
    return false unless user
    user.supports.where(proposal: self).any?
  end

  def self.filter(filtering_params)
    results = self.reddit
    results = results.public_send(filtering_params) if filtering_params.present?
    results
  end

  def hotness
    supports.count + (days_since_created * 1000)
  end

  def days_since_created
    ((Time.now - created_at)/60/60/24).to_i
  end

end