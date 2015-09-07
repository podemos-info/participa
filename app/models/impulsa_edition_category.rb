class ImpulsaEditionCategory < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects

  validates :name, :category_type, :winners, :prize, presence: true

  scope :non_authors, -> { where.not only_authors:true }
  CATEGORY_TYPES = {
    internal: 0, 
    state: 1, 
    territorial: 2 
  }

  def category_type_name
    CATEGORY_TYPES.invert[self.category_type]
  end

  def needs_authority?
    self.category_type == CATEGORY_TYPES[:internal]
  end

  def needs_project_details?
    self.category_type != CATEGORY_TYPES[:internal]
  end

  def needs_additional_details?
    self.category_type == CATEGORY_TYPES[:state]
  end

  def allows_organization_types?
    self.category_type == CATEGORY_TYPES[:territorial]
  end

  def has_territory?
    self.category_type == CATEGORY_TYPES[:territorial]
  end

  def translatable?
    !self.coofficial_language.blank?
  end

  def coofficial_language_name
     I18n.name_for_locale(self[:coofficial_language].to_sym) if self[:coofficial_language]
  end

  def territories
    if self[:territories]
      self[:territories].split("|").compact 
    else
      []
    end
  end

  def territories= values
    self[:territories] = values.select {|x| !x.blank? } .join("|")
  end

  def territories_names
    names = Hash[Podemos::GeoExtra::AUTONOMIES.values]
    self.territories.map {|t| names[t]}
  end
end
