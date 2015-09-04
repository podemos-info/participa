class ImpulsaEditionCategory < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects

  validates :name, :category_type, :winners, :prize, presence: true

  CATEGORY_TYPES = {
    "Interna" => 1, 
    "Estatal" => 2, 
    "Territorial" => 3 
  }

  def category_type_name
    ImpulsaEditionCategory::CATEGORY_TYPES.invert[self.category_type]
  end

  def has_territory?
    self.category_type == CATEGORY_TYPES["Territorial"]
  end

  def needs_authority?
    self.category_type == CATEGORY_TYPES["Interna"]
  end
end
