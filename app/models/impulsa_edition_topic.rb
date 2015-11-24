class ImpulsaEditionTopic < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects
end
