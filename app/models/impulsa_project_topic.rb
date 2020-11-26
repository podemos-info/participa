class ImpulsaProjectTopic < ApplicationRecord
  belongs_to :impulsa_project
  belongs_to :impulsa_edition_topic

  def slug
    self.name.parametrize
  end
end
