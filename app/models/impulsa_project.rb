class ImpulsaProject < ActiveRecord::Base
  belongs_to :impulsa_edition_category
  belongs_to :user, -> { with_deleted }
  has_one :impulsa_edition, through: :impulsa_edition_category

  belongs_to :evaluator1, class_name: "User"
  belongs_to :evaluator2, class_name: "User"

  has_many :impulsa_project_topics, dependent: :destroy
  has_many :impulsa_edition_topics, through: :impulsa_project_topics

  has_attached_file :logo, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension", styles: { medium: "300x300>", thumb: "100x100>" }
  has_attached_file :scanned_nif, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :endorsement, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :register_entry, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :statutes, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :responsible_nif, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :fiscal_obligations_certificate, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :labor_obligations_certificate, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :home_certificate, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :bank_certificate, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :last_fiscal_year_report_of_activities, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :last_fiscal_year_annual_accounts, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :schedule, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :activities_resources, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :requested_budget, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :monitoring_evaluation, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :evaluator1_analysis, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"
  has_attached_file :evaluator2_analysis, url: '/impulsa/:id/attachment/:field/:style/:filename', path: ":rails_root/non-public/system/:class/:id/:field/:style/:basename.:extension"

  validates :user, uniqueness: {scope: :impulsa_edition_category}, allow_blank: false, allow_nil: false, unless: Proc.new { |project| project.user.nil? || project.user.impulsa_author? }
  validates :name, :impulsa_edition_category_id, :status, presence: true

  attr_accessor :check_validation, :mark_as_reviewed
  validate if: -> { self.check_validation || self.should_be_valid? } do |project|
    project.user_editable_fields.each do |field|
      if [ :terms_of_service, :data_truthfulness, :content_rights ].member?(field)
        next
      elsif FIELDS[:translation].member?(field)
        next if !project.translated? || !project.user_view_field?(field.to_s.sub("coofficial_", "").to_sym)
      elsif FIELDS[:optional].member?(field)
        next
      elsif FIELDS[:optional_certificates].member?(field) && project.optional_certificates?
        next
      end
      project.validates_presence_of field
    end
  end

  validates :authority_email, allow_blank: true, email: true
  validates :organization_web, :video_link, allow_blank: true, url: true
  validates :organization_year, allow_blank: true, numericality: { only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: Date.today.year }

  validates :terms_of_service, :data_truthfulness, :content_rights, acceptance: true, unless: :check_validation

  validate if: -> { self.check_validation || self.should_be_valid? } do |project|
    project.errors[:impulsa_edition_topics] << "hay demasiadas temáticas para el proyecto" if project.impulsa_edition_topics.size > 2
  end

  validates_attachment :logo, content_type: { content_type: ["image/jpeg", "image/jpg", "image/gif", "image/png"]}, size: { less_than: 2.megabyte }
  validates_attachment :scanned_nif, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :endorsement, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :register_entry, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :statutes, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :responsible_nif, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :fiscal_obligations_certificate, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :labor_obligations_certificate, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :home_certificate, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :bank_certificate, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :last_fiscal_year_report_of_activities, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :last_fiscal_year_annual_accounts, content_type: { content_type: ["application/pdf", "application/x-pdf"]}, size: { less_than: 2.megabyte }
  validates_attachment :schedule, content_type: { content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]}, size: { less_than: 2.megabyte }
  validates_attachment :activities_resources, content_type: { content_type: [ "application/vnd.ms-word", "application/msword", "application/x-msword", "application/x-ms-word", "application/x-word", "application/x-dos_ms_word", "application/doc", "application/x-doc", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.oasis.opendocument.text" ]}, size: { less_than: 2.megabyte }
  validates_attachment :requested_budget, content_type: { content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]}, size: { less_than: 2.megabyte }
  validates_attachment :evaluator1_analysis, content_type: { content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]}, size: { less_than: 2.megabyte }
  validates_attachment :evaluator2_analysis, content_type: { content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]}, size: { less_than: 2.megabyte }
  
  attr_accessor :mark_as_viewed, :invalid_reasons, :evaluator_analysis

  attr_accessor :logo_cache, :scanned_nif_cache, :endorsement_cache, :register_entry_cache, :statutes_cache, :responsible_nif_cache, :fiscal_obligations_certificate_cache, :labor_obligations_certificate_cache, :home_certificate_cache, :bank_certificate_cache, :last_fiscal_year_report_of_activities_cache, :last_fiscal_year_annual_accounts_cache, :schedule_cache, :activities_resources_cache, :requested_budget_cache, :monitoring_evaluation_cache

  def cache_project_files
    @logo_cache = cache_files( logo, @logo_cache, lambda {|f| assign_attributes(logo: f)} )
    @scanned_nif_cache = cache_files( scanned_nif, @scanned_nif_cache, lambda {|f| assign_attributes(scanned_nif: f)} )
    @endorsement_cache = cache_files( endorsement, @endorsement_cache, lambda {|f| assign_attributes(endorsement: f)} )
    @register_entry_cache = cache_files( register_entry, @register_entry_cache, lambda {|f| assign_attributes(register_entry: f)} )
    @statutes_cache = cache_files( statutes, @statutes_cache, lambda {|f| assign_attributes(statutes: f)} )
    @responsible_nif_cache = cache_files( responsible_nif, @responsible_nif_cache, lambda {|f| assign_attributes(responsible_nif: f)} )
    @fiscal_obligations_certificate_cache = cache_files( fiscal_obligations_certificate, @fiscal_obligations_certificate_cache, lambda {|f| assign_attributes(fiscal_obligations_certificate: f)} )
    @labor_obligations_certificate_cache = cache_files( labor_obligations_certificate, @labor_obligations_certificate_cache, lambda {|f| assign_attributes(labor_obligations_certificate: f)} )
    @home_certificate_cache = cache_files( home_certificate, @home_certificate_cache, lambda {|f| assign_attributes(home_certificate: f)} )
    @bank_certificate_cache = cache_files( bank_certificate, @bank_certificate_cache, lambda {|f| assign_attributes(bank_certificate: f)} )
    @last_fiscal_year_report_of_activities_cache = cache_files( last_fiscal_year_report_of_activities, @last_fiscal_year_report_of_activities_cache, lambda {|f| assign_attributes(last_fiscal_year_report_of_activities: f)} )
    @last_fiscal_year_annual_accounts_cache = cache_files( last_fiscal_year_annual_accounts, @last_fiscal_year_annual_accounts_cache, lambda {|f| assign_attributes(last_fiscal_year_annual_accounts: f)} )
    @schedule_cache = cache_files( schedule, @schedule_cache, lambda {|f| assign_attributes(schedule: f)} )
    @activities_resources_cache = cache_files( activities_resources, @activities_resources_cache, lambda {|f| assign_attributes(activities_resources: f)} )
    @requested_budget_cache = cache_files( requested_budget, @requested_budget_cache, lambda {|f| assign_attributes(requested_budget: f)} )
    @monitoring_evaluation_cache = cache_files( monitoring_evaluation, @monitoring_evaluation_cache, lambda {|f| assign_attributes(monitoring_evaluation: f)} )
  end
  
  scope :by_status, ->(status) { where( status: status ) }

  scope :first_phase, -> { where( status: [ 0, 1, 2, 3 ] ) }
  scope :second_phase, -> { where( status: [ 4, 6 ]) }
  scope :no_phase, -> { where status: [ 5, 7, 10 ] } 

  PROJECT_STATUS = {
    new: 0,
    review: 1,
    fixes: 2,
    review_fixes: 3,
    validate: 4,
    invalidated: 5,
    validated: 6,
    discarded: 7,
    resigned: 8,
    winner: 9,
    spam: 10,
    dissent: 11
  }

  FIELDS = {
    admin: [ :user_id, :status, :review_fields, :counterpart_information, :additional_contact ],
    impulsa_admin: [ :user_id, :review_fields, :counterpart_information, :additional_contact ],
    always: [ :impulsa_edition_category_id, :name ],
    with_category: [ :short_description, :logo, :video_link ],
    authority: [ :authority, :authority_name, :authority_phone, :authority_email ],
    organization_types: [ :organization_type ],
    full_organization: [ :organization_name, :organization_address, :organization_web, :organization_nif, :scanned_nif, :organization_year, :organization_legal_name, :organization_legal_nif, :organization_mission, :register_entry, :statutes ],
    non_organization: [ :career ],
    not_in_spain: [ :home_certificate, :bank_certificate ],
    non_project_details: [ :additional_contact, :total_budget ],
    project_details: [ :impulsa_edition_topics, :territorial_context, :long_description, :aim, :metodology, :population_segment, :schedule, :activities_resources, :requested_budget, :counterpart, :impulsa_edition_topic_ids, :endorsement, :responsible_nif, :fiscal_obligations_certificate, :labor_obligations_certificate, :total_budget],
    additional_details: [ :last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :monitoring_evaluation ], 
    translation: [ :coofficial_translation, :coofficial_name, :coofficial_short_description, :coofficial_video_link, :coofficial_territorial_context, :coofficial_long_description, :coofficial_aim, :coofficial_metodology, :coofficial_population_segment, :coofficial_career, :coofficial_organization_mission ],
    update: [ :terms_of_service, :data_truthfulness, :content_rights ],

    optional: [ :counterpart, :last_fiscal_year_report_of_activities, :last_fiscal_year_annual_accounts, :video_link ],
    optional_certificates: [ :fiscal_obligations_certificate, :labor_obligations_certificate ]
  }


  ALL_FIELDS = FIELDS.map {|k,v| v} .flatten.uniq
  ADMIN_REVIEWABLE_FIELDS = FIELDS[:always] + FIELDS[:with_category] + FIELDS[:authority] + FIELDS[:organization_types] + FIELDS[:full_organization] + FIELDS[:non_organization] + FIELDS[:not_in_spain] + FIELDS[:non_project_details] + FIELDS[:project_details] + FIELDS[:additional_details] + FIELDS[:translation]

  ORGANIZATION_TYPES = {
    organization: 0,
    people: 1,
    foreign_people: 2
  }

  def new?
    self.status==PROJECT_STATUS[:new]
  end

  def review?
    self.status==PROJECT_STATUS[:review]
  end

  def fixes?
    self.status==PROJECT_STATUS[:fixes]
  end

  def spam?
    self.status==PROJECT_STATUS[:spam]
  end

  def allow_save_draft?
    self.new? || self.spam? || self.fixes? || (self.marked_for_review? && self.errors.any?)
  end

  def marked_for_review?
    self.status==PROJECT_STATUS[:review] || self.status==PROJECT_STATUS[:review_fixes]
  end

  def marked_as_validable?
    self.status==PROJECT_STATUS[:validate]
  end

  def should_be_valid?
    self.marked_for_review? || self.marked_as_validable?
  end

  def mark_as_new
    self.status=PROJECT_STATUS[:new] if self.review? || self.spam?
  end

  def mark_as_spam
    self.status=PROJECT_STATUS[:spam] if self.new?
  end

  def mark_for_review
    if self.new? || self.spam?
      self.status=PROJECT_STATUS[:review]
    elsif self.fixes?
      self.status=PROJECT_STATUS[:review_fixes]
    end
  end

  def mark_as_fixable
    self.status=PROJECT_STATUS[:fixes]
  end

  def mark_as_validable
    self.status=PROJECT_STATUS[:validate]
  end    

  def editable?
    !persisted? || (self.impulsa_edition.allow_edition? && (self.status < PROJECT_STATUS[:fixes] || self.spam?))
  end

  def reviewable?
    self.impulsa_edition.allow_fixes? && (marked_for_review? || new? || fixes?)
  end

  def saveable?
    editable? || reviewable?
  end

  def validable?
    self.status==PROJECT_STATUS[:validate] && self.impulsa_edition.allow_validation?
  end

  def invalidated?
    self.status==PROJECT_STATUS[:invalidated]
  end

  def validated?
    self.status==PROJECT_STATUS[:validated]
  end

  def check_validation
    return if !self.evaluator1_analysis.exists? || !self.evaluator2_analysis.exists?
    valid1 = evaluator1_invalid_reasons.blank?
    valid2 = evaluator2_invalid_reasons.blank?
    if valid1 && valid2
      self.status = PROJECT_STATUS[:validated]
    elsif !valid1 && !valid2
      self.status = PROJECT_STATUS[:invalidated]
    else
      self.status = PROJECT_STATUS[:dissent]
    end 
  end

  def preload params
    if params
      self.impulsa_edition_category_id = params[:impulsa_edition_category_id] if params[:impulsa_edition_category_id]
      if self.allows_organization_types?
        self.organization_type = params[:organization_type] if params[:organization_type]
        self.organization_type = 0 if self.organization_type.nil?
      end
    end
  end

  def user_view_field? field
    user_viewable_fields.member? field
  end

  def field_class field
    if self.errors.include? field
      "with_errors"
    elsif !user_viewable_fields.member?(field)
      "no_viewable"
    else
      ""
    end
  end

  def user_viewable_fields
    fields = FIELDS[:always]

    if self.impulsa_edition_category
      fields += FIELDS[:with_category]
      fields += FIELDS[:translation] if self.translatable?

      fields += FIELDS[:authority] if self.needs_authority?

      if self.needs_organization?
        fields += FIELDS[:full_organization]
      else
        fields += FIELDS[:non_organization]
      end
      
      if self.needs_project_details?
        fields += FIELDS[:project_details] 
        fields += FIELDS[:organization_types] if self.allows_organization_types?
        fields += FIELDS[:not_in_spain] if self.not_in_spain?
        fields += FIELDS[:additional_details] if self.needs_additional_details?
      else
        fields += FIELDS[:non_project_details] 
      end
      fields += FIELDS[:update] if self.saveable?
    end
    fields.uniq
  end

  def user_edit_field? field
    user_editable_fields.member? field
  end
  
  def user_editable_fields
    if self.editable?
      self.user_viewable_fields
    elsif self.reviewable?
      fields = review_fields.symbolize_keys.keys
      fields
    else
      []
    end
  end

  def status_name
    ImpulsaProject::STATUS_NAMES.invert[self.status]
  end

  def organization_type_name
    ImpulsaProject::ORGANIZATION_TYPES.invert[self.organization_type]
  end

  def needs_authority?
    self.impulsa_edition_category.needs_authority? if self.impulsa_edition_category
  end

  def needs_project_details?
    self.impulsa_edition_category.needs_project_details? if self.impulsa_edition_category
  end

  def needs_additional_details?
    self.impulsa_edition_category.needs_additional_details? if self.impulsa_edition_category
  end

  def allows_organization_types?
    self.impulsa_edition_category.allows_organization_types? if self.impulsa_edition_category
  end

  def optional_certificates?
    (self.impulsa_edition_category.allows_organization_types? if self.impulsa_edition_category) && self.organization_type == 1
  end

  def needs_organization?
    (self.impulsa_edition_category.needs_additional_details? if self.impulsa_edition_category) || self.organization_type == 0
  end

  def not_in_spain?
    self.organization_type == 2
  end

  def translated?
    self.translatable? && self.coofficial_translation?
  end

  def translatable?
    self.impulsa_edition_category.translatable? if self.impulsa_edition_category
  end

  def locale
    impulsa_edition_category.coofficial_language
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

  # paperclip duplicate errors: adds all to :field and one error to :field_[column] (file_name, content_type, file_size)
  # we use only errors from :field
  def clear_extra_file_errors
    ImpulsaProject.attachment_definitions.keys.each do |field|
      errors.delete(:"#{field}_file_name")
      errors.delete(:"#{field}_content_type")
      errors.delete(:"#{field}_file_size")
    end
  end

  def user_editable_cache_fields
    ImpulsaProject.attachment_definitions.keys.select { |field| self.user_edit_field?(field) }.map do |field|
      :"#{field}_cache"
    end
  end

  def has_attachment_field? field_name
    ImpulsaProject.attachment_definitions.keys.member? field_name.to_sym
  end
end