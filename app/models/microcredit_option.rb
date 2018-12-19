class MicrocreditOption < ActiveRecord::Base
  belongs_to :microcredit

  validates :name, presence: true


end
