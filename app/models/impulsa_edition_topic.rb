class ImpulsaEditionTopic < ApplicationRecord
  belongs_to :impulsa_edition
  has_many :impulsa_projects
end
