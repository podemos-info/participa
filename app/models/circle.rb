class Circle < ActiveRecord::Base

  TERRITORY_PREFIX = "T"

  def is_active?
    self.code[0] == TERRITORY_PREFIX
  end
end
