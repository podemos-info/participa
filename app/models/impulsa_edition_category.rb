class ImpulsaEditionCategory < ActiveRecord::Base
  belongs_to :impulsa_edition
  has_many :impulsa_projects

  validates :name, :category_type, :winners, :prize, presence: true

  store :wizard, coder: YAML
  attr_accessor :wizard_raw

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


#   has_attached_file :schedule_model_override
#   has_attached_file :activities_resources_model_override
#   has_attached_file :requested_budget_model_override
#   has_attached_file :monitoring_evaluation_model_override

#   validates_attachment_content_type :schedule_model_override, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
#   validates_attachment_content_type :activities_resources_model_override, content_type: [  "application/vnd.ms-word", "application/msword", "application/x-msword", "application/x-ms-word", "application/x-word", "application/x-dos_ms_word", "application/doc", "application/x-doc", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.oasis.opendocument.text" ]
#   validates_attachment_content_type :requested_budget_model_override, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
#   validates_attachment_content_type :monitoring_evaluation_model_override, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]


#   def needs_authority?
#     self.category_type == CATEGORY_TYPES[:internal]
#   end

#   def needs_project_details?
#     self.category_type != CATEGORY_TYPES[:internal]
#   end

#   def needs_preselection?
#     self.category_type == CATEGORY_TYPES[:state]
#   end

#   def needs_additional_details?
#     self.category_type == CATEGORY_TYPES[:state]
#   end

#   def allows_organization_types?
#     self.category_type == CATEGORY_TYPES[:territorial]
#   end


#   def schedule_model
#     self.schedule_model_override.exists? ? self.schedule_model_override : self.impulsa_edition.schedule_model
#   end

#   def activities_resources_model
#     self.activities_resources_model_override.exists? ? self.activities_resources_model_override : self.impulsa_edition.activities_resources_model
#   end

#   def requested_budget_model
#     self.requested_budget_model_override.exists? ? self.requested_budget_model_override : self.impulsa_edition.requested_budget_model
#   end

#   def monitoring_evaluation_model
#     self.monitoring_evaluation_model_override.exists? ? self.monitoring_evaluation_model_override : self.impulsa_edition.monitoring_evaluation_model
#   end

#   def options base_url
#     self.impulsa_projects.votable.map do |project|
#       image_url = if project.video_id
#                     "https://www.youtube.com/watch?v=#{project.video_id}"
#                   elsif project.logo.exists?
#                     URI.join(base_url, project.logo.url(:medium)).to_s
#                   else
#                     ""
#                   end
#       [ project.name, image_url, URI.join(base_url, Rails.application.routes.url_helpers.impulsa_project_path(id: project.id)).to_s, project.short_description.gsub("\r\n"," ").gsub("\n"," ").gsub("\t"," ") ].join("\t")
#     end .join "\n"
#   end
# end
