class Circle < ActiveRecord::Base
  has_many :users

  TERRITORY_PREFIX = "T"

  def is_active?
    self.code[0] == TERRITORY_PREFIX
  end
end
