class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  
  scope :active, -> { joins(:posts).distinct('id') }

  has_and_belongs_to_many :posts

  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end
end
