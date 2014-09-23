class Vote < ActiveRecord::Base

  belongs_to :user
  belongs_to :election

  validates :user_id, :election_id, :voter_id, presence: true
  validates :user_id, uniqueness: {scope: :election_id}
  validates :voter_id, uniqueness: true

  before_validation :save_voter_id, on: :create

  def generate_voter_id
    Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{self.user_id}:#{self.election_id}")
  end

  def generate_message
    "#{self.voter_id}:#{self.election.agora_election_id}:#{Time.now.to_i}"
  end

  def generate_hash(message)
    key = Rails.application.secrets.agora["shared_key"]
    Digest::HMAC.hexdigest(message, key, Digest::SHA256)
  end

  def url
    key = Rails.application.secrets.agora["shared_key"]
    message =  self.generate_message
    hash = self.generate_hash message
    "http://agoravoting.org/agora-core-view/dist#/test_hmac/#{key}/#{hash}/#{message}"
  end

  private

  def save_voter_id
    self.update_attribute(:voter_id, generate_voter_id)
  end

end
