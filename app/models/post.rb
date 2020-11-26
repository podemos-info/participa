class Post < ApplicationRecord
  acts_as_paranoid
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  has_and_belongs_to_many :categories

  STATUS = {"Borrador" => 0, "Publicado" => 1}

  scope :index, -> { order(created_at: :desc)}
  scope :created, -> { where(deleted_at: nil) }
  scope :drafts,  -> { where(status: 0) }
  scope :published,  -> { where(status: 1) }
  scope :deleted, -> { only_deleted }

  validates :title, :status, presence: true

  def published?
    status>0
  end

  def slug_candidates
    [
      :title,
      [:title, DateTime.now.year],
      [:title, DateTime.now.year, DateTime.now.month],
      [:title, DateTime.now.year, DateTime.now.month, DateTime.now.day]
    ]
  end

  auto_html_for :content do
    simple_format
    link(target: "_blank")
    youtube(width: 400, height: 250)
    vimeo(width: 400, height: 250)
    image
  end
end
