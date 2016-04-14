class Vote < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  belongs_to :election

  validates :user_id, :election_id, :voter_id, presence: true
  #validates :user_id, uniqueness: {scope: :election_id}
  validates :voter_id, uniqueness: {scope: :user_id}

  before_validation :save_voter_id, on: :create

  def generate_voter_id
    Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{self.user_id}:#{self.election_id}:#{self.scoped_agora_election_id}")
  end

  def generate_message
    "#{self.voter_id}:AuthEvent:#{self.scoped_agora_election_id}:vote:#{Time.now.to_i}"
  end

  def generate_hash(message)
    key = self.election.server_shared_key
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new('sha256'), key, message)
  end

  def scoped_agora_election_id
    self.election.scoped_agora_election_id self.user
  end

  def url
    key = self.election.server_shared_key
    message =  self.generate_message
    hash = self.generate_hash message
    "#{self.election.server_url}booth/#{self.scoped_agora_election_id}/vote/#{hash}/#{message}"
  end

  def test_url
    key = self.election.server_shared_key
    message =  self.generate_message
    hash = self.generate_hash message
    "#{self.election.server_url}test_hmac/#{key}/#{hash}/#{message}"
  end

  private

  def save_voter_id
    if self.election and self.user
      self.update_attribute(:voter_id, generate_voter_id)
    else
      self.errors.add(:voter_id, "No se pudo generar")
    end
  end

end
