class ParticipationTeam < ActiveRecord::Base
    has_and_belongs_to_many :user
end
