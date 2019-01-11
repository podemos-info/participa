class MicrocreditOption < ActiveRecord::Base
  belongs_to :microcredit
  belongs_to :parent, class_name: "MicrocreditOption"
  has_many :children, foreign_key: :parent_id, class_name: "MicrocreditOption", inverse_of: :parent
  validates :name, presence: true

  scope :root_parents, -> {where(parent_id: nil)}
  scope :without_children, -> { includes(:children).where("children_microcredit_options"=>{id:nil})}

end
