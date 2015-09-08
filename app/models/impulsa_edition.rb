class ImpulsaEdition < ActiveRecord::Base
  store :legal, accessors: I18n.available_locales.map {|l| "legal_#{l}"}, coder: YAML

  has_many :impulsa_edition_categories
  has_many :impulsa_projects, through: :impulsa_edition_categories
  has_many :impulsa_edition_topics
  
  has_attached_file :schedule_model
  has_attached_file :activities_resources_model
  has_attached_file :requested_budget_model
  has_attached_file :monitoring_evaluation_model

  validates :name, presence: true

  validates *I18n.available_locales.map {|l| "legal_#{l}".to_sym }, allow_blank: true, url: true

  validates_attachment_content_type :schedule_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :activities_resources_model, content_type: [  "application/vnd.ms-word", "application/msword", "application/x-msword", "application/x-ms-word", "application/x-word", "application/x-dos_ms_word", "application/doc", "application/x-doc", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/vnd.oasis.opendocument.text" ]
  validates_attachment_content_type :requested_budget_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]
  validates_attachment_content_type :monitoring_evaluation_model, content_type: [ "application/vnd.ms-excel", "application/msexcel", "application/x-msexcel", "application/x-ms-excel", "application/x-excel", "application/x-dos_ms_excel", "application/xls", "application/x-xls", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.oasis.opendocument.spreadsheet" ]

  scope :active, -> { where("? BETWEEN start_at AND ends_at", DateTime.now) }
  scope :upcoming, -> { where("start_at > ?", DateTime.now) }

  def self.current
    active.first
  end

  EDITION_PHASES = {
    not_started: 0,
    new_projects: 1,
    review_projects: 2,
    validation_projects: 3,
    votings: 4,
    ended: 5
  }
  def current_phase
    now = DateTime.now
    if now < self.start_at
      EDITION_PHASES[:not_started]
    elsif now < self.new_projects_until
      EDITION_PHASES[:new_projects]
    elsif now < self.review_projects_until
      EDITION_PHASES[:review_projects]
    elsif now < self.validation_projects_until
      EDITION_PHASES[:validation_projects]
    elsif now < self.ends_at
      EDITION_PHASES[:votings]
    else
      EDITION_PHASES[:ended]
    end
  end

  def legal_link
    self[:legal]["legal_#{I18n.locale}"] || self[:legal]["legal_#{I18n.default_locale}"]
  end
end
