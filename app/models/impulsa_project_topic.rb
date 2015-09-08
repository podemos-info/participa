class ImpulsaProjectTopic < ActiveRecord::Base
  belongs_to :impulsa_project
  belongs_to :impulsa_edition_topic
  validates_associated :impulsa_project, :message => "Ya hay demasiadas temáticas para el proyecto."
end
