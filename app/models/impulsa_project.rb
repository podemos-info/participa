class ImpulsaProject < ActiveRecord::Base
  belongs_to :impulsa_edition_category
  belongs_to :user
  has_one :impulsa_edition, through: :impulsa_edition_category
  has_many :impulsa_project_attachments

  has_many :impulsa_project_topics
  has_many :impulsa_edition_topics, through: :impulsa_project_topics

  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  has_attached_file :scanned_nif
  has_attached_file :endorsement
  has_attached_file :register_entry
  has_attached_file :statutes
  has_attached_file :responsible_nif
  has_attached_file :fiscal_obligations_certificate
  has_attached_file :labor_obligations_certificate
  has_attached_file :home_certificate
  has_attached_file :bank_certificate
  has_attached_file :last_fiscal_year_report_of_activities
  has_attached_file :last_fiscal_year_annual_accounts
  has_attached_file :schedule
  has_attached_file :activities_resources
  has_attached_file :requested_budget
  has_attached_file :monitoring_evaluation

  validates :user, uniqueness: {scope: :impulsa_edition_category}, allow_blank: false, allow_nil: false
  validates :name, presence: true
  validates :authority_email, allow_blank: true, email: true
  validates :organization_web, :video_link, allow_blank: true, url: true
  validates :organization_year, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: Date.today.year }

  validates :terms_of_service, :data_truthfulness, acceptance: true

  validates_each :impulsa_edition_topics do |project, attr, value|
    project.errors.add attr, "Demasiadas temáticas para el proyecto" if project.impulsa_edition_topics.size > 2
  end

  validates_attachment_content_type :logo, content_type: ["image/jpeg", "image/jpg", "image/gif", "image/png"]
  validates_attachment_content_type :scanned_nif, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :endorsement, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :register_entry, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :statutes, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :responsible_nif, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :fiscal_obligations_certificate, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :labor_obligations_certificate, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :home_certificate, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :bank_certificate, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :last_fiscal_year_report_of_activities, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :last_fiscal_year_annual_accounts, content_type: ["application/pdf", "application/x-pdf"]
  validates_attachment_content_type :schedule, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :activities_resources, content_type: [ "application/vnd.ms-word", "application/msword", "application/x-msword", "application/x-ms-word", "application/x-word", "application/x-dos_ms_word", "application/doc", "application/x-doc", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.oasis.opendocument.text" ]
  validates_attachment_content_type :requested_budget, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :monitoring_evaluation, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]

  scope :by_status, ->(status) { where( status: status ) }

  STATUS_NAMES = {
    "Nuevo" => 0,
    "Corregir" => 1,
    "Corregible" => 2,
    "Por validar" => 3,
    "Validado" => 4,
    "No seleccionado" => 5,
    "Descartado" => 6,
    "Renuncia" => 7,
    "Premiado" => 8
  }

  USER_EDITABLE_FIELDS = [ :impulsa_edition_category_id, :name, :authority, :authority_name, :authority_phone, :authority_email, :organization_type, :organization_name, :organization_address, :organization_web, :organization_nif, :organization_year, :organization_legal_name, :organization_legal_nif, :organization_mission, :career, :additional_contact, :counterpart, :territorial_context, :short_description, :long_description, :aim, :metodology, :population_segment, :video_link, :alternative_language, :alternative_name, :alternative_organization_mission, :alternative_career, :alternative_territorial_context, :alternative_short_description, :alternative_long_description, :alternative_aim, :alternative_metodology, :alternative_population_segment, :scanned_nif, :logo, :endorsement, :register_entry, :statutes, :responsible_nif, :fiscal_obligations_certificate, :labor_obligations_certificate, :last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :schedule, :activities_resources, :requested_budget, :monitoring_evaluation, :endorsement, :register_entry, :statutes, :responsible_nif, :fiscal_obligations_certificate, :labor_obligations_certificate, :home_certificate, :bank_certificate,:last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :impulsa_edition_topic_ids, :terms_of_service, :data_truthfulness ]
  ALL_FIELDS = USER_EDITABLE_FIELDS + [ :user_id, :status, :review_fields,  :counterpart_information ]
  ORGANIZATION_TYPE_NAMES = {
    "Entidad constituida" => 0,
    "Grupo de personas" => 1,
    "Residentes en el extranjero" => 2
  }

  ALTERNATIVE_LANGUAGES = {
    "ca" => "Català",
    "eu" => "Euskera",
    "ga" => "Galego"
  }

  def new?
    self.status==0
  end

  def mark_for_review
    self.status=1
  end
  
  def editable?
    self.status < 3 && self.impulsa_edition.current_phase < ImpulsaEdition::EDITION_PHASES[:validation_projects]
  end

  def reviewable?
    persisted? and editable?
  end

  def user_editable_fields
    case self.status
      when 0
        ImpulsaProject::USER_EDITABLE_FIELDS
      when 1..2
        review_fields.symbolize_keys.keys
      else
        []
      end
  end

  def status_name
    ImpulsaProject::STATUS_NAMES.invert[self.status]
  end

  def organization_type_name
    ImpulsaProject::ORGANIZATION_TYPE_NAMES.invert[self.organization_type]
  end

  def needs_authority?
    self.impulsa_edition_category.needs_authority? if self.impulsa_edition_category
  end

  def needs_aditional_info?
    self.impulsa_edition_category.needs_aditional_info? if self.impulsa_edition_category
  end

  def needs_aditional_documents?
    self.impulsa_edition_category.needs_aditional_documents? if self.impulsa_edition_category
  end

  def allows_organization_types?
    self.impulsa_edition_category.allows_organization_types? if self.impulsa_edition_category
  end

  def needs_organization?
    (self.impulsa_edition_category.needs_aditional_documents? if self.impulsa_edition_category) || self.organization_type == 0
  end

  def is_in_spain?
    (!self.impulsa_edition_category.allows_organization_types? if self.impulsa_edition_category) || self.organization_type != 2
  end

  def organization_type
    self[:organization_type] if self.allows_organization_types?
  end

  def review_fields
    @review_fields ||= (YAML.load(self[:review_fields]) if self[:review_fields]) || {}
  end

  def method_missing(method_sym, *arguments, &block)
    method = method_sym.to_s
    if method =~ /^(.*)_review=?$/
      if method.last=="="
        if arguments.first.blank?
          review_fields.delete method[0..-9].to_sym
        else
          review_fields[method[0..-9].to_sym] = arguments.first
        end
        self[:review_fields] = review_fields.to_yaml
      else
        review_fields[method[0..-8].to_sym]
      end
    else
      super
    end
  end

  def respond_to?(name)
    name =~ /^(.*)_review=?$/ || super
  end
end
