# frozen_string_literal: true

class Vote < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :election
  belongs_to :paper_authority, class_name: "User"

  validates :user_id, :election_id, :voter_id, presence: true
  validates :voter_id, uniqueness: { scope: :user_id }

  before_validation :save_voter_id, on: :create

  def generate_voter_id
    Digest::SHA256.hexdigest(
      (
        election.voter_id_template.presence ||
        '%{secret_key_base}:%{user_id}:%{election_id}:%{scoped_agora_election_id}'
      ) % voter_id_template_values
    )
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
      self.update_attribute(:agora_id, scoped_agora_election_id)
      self.update_attribute(:voter_id, generate_voter_id)
    else
      self.errors.add(:voter_id, 'No se pudo generar')
    end
  end

  def voter_id_template_values
    @voter_id_template_values ||= Hash.new do |hash, key|
      hash[key] = case key
                  when :shared_secret then election.server_shared_key
                  when :normalized_vatid then normalized_vatid(!user.is_passport?, user.document_vatid)
                  when :secret_key_base then Rails.application.secrets.secret_key_base
                  when :user_id then user_id
                  when :election_id then election_id
                  when :scoped_agora_election_id then scoped_agora_election_id
                  else '%{key}'
                  end
    end
  end

  def normalized_vatid(spanish_nif, document_vatid)
    (spanish_nif ? 'DNI' : 'PASS') + normalize_identifier(document_vatid)
  end

  def normalize_identifier(identifier)
    identifier.gsub(/[^a-zA-Z0-9]/, '')
              .upcase
              .each_char
              .chunk_while { |i, j| number?(i) == number?(j) }
              .map(&:join)
              .map { |part| part.gsub(/^0*/, '') }
              .join
  end

  NUMBERS = ('0'..'9').to_set
  def number?(char)
    NUMBERS.include?(char)
  end
end
