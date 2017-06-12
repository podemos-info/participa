class Group < ActiveRecord::Base

  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true

  attr_accessor :members

end
