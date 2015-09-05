class ImpulsaEditionCategory < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects

  validates :name, :category_type, :winners, :prize, presence: true

  CATEGORY_TYPES = {
    "Organización" => 0, 
    "Estatal" => 1, 
    "Territorial" => 2 
  }

  def category_type_name
    ImpulsaEditionCategory::CATEGORY_TYPES.invert[self.category_type]
  end

  def needs_authority?
    self.category_type == CATEGORY_TYPES["Organización"]
  end

  def needs_aditional_info?
    self.category_type != CATEGORY_TYPES["Organización"]
  end

  def needs_aditional_documents?
    self.category_type == CATEGORY_TYPES["Estatal"]
  end

  def allows_organization_types?
    self.category_type == CATEGORY_TYPES["Territorial"]
  end

  def has_territory?
    self.category_type == CATEGORY_TYPES["Territorial"]
  end
end
