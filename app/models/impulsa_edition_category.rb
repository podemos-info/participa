class ImpulsaEditionCategory < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects

  validates :name, :category_type, :winners, :prize, presence: true

  store :wizard, coder: YAML
  store :evaluation, coder: YAML
  attr_accessor :wizard_raw, :evaluation_raw

  scope :non_authors, -> { where.not only_authors:true }
  scope :state, -> { where category_type: CATEGORY_TYPES[:state] }
  scope :territorial, -> { where category_type: CATEGORY_TYPES[:territorial] }
  scope :internal, -> { where category_type: CATEGORY_TYPES[:internal] }
  
  CATEGORY_TYPES = {
    internal: 0, 
    state: 1, 
    territorial: 2 
  }

  def wizard_raw
    self.wizard.to_yaml.gsub(" !ruby/hash:ActiveSupport::HashWithIndifferentAccess", "")
  end

  def wizard_raw=(value)
    self.wizard=YAML.load(value)
  end

  def evaluation_raw
    self.evaluation.to_yaml.gsub(" !ruby/hash:ActiveSupport::HashWithIndifferentAccess", "")
  end

  def evaluation_raw=(value)
    self.evaluation=YAML.load(value)
  end
  
  def category_type_name
    CATEGORY_TYPES.invert[self.category_type]
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

  def prewinners
    self.winners*2
  end
end