class ParticipationTeam < ApplicationRecord
  has_and_belongs_to_many :user

	scope :active, -> { where(active: true)  }
end
