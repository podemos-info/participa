class Election < ActiveRecord::Base

  validates :title, :starts_at, :ends_at, :agora_election_id, presence: true
  has_many :votes

  scope :actived, -> { where("? BETWEEN starts_at AND ends_at", Time.now)}

end
