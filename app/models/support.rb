class Support < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :proposal, dependent: :destroy
end
